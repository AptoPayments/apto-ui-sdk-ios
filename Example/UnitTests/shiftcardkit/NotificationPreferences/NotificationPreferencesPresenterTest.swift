//
// NotificationPreferencesPresenterTest.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 08/03/2019.
//

import XCTest
@testable import AptoSDK
@testable import AptoUISDK

class NotificationPreferencesPresenterTest: XCTestCase {
  private var sut: NotificationPreferencesPresenter! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let router = NotificationPreferencesModuleSpy(serviceLocator: ServiceLocatorFake())
  private let interactor = NotificationPreferencesInteractorFake()
  private let notificationPreferences = ModelDataProvider.provider.notificationPreferences

  override func setUp() {
    super.setUp()

    sut = NotificationPreferencesPresenter()
    sut.router = router
    sut.interactor = interactor
  }

  func testViewLoadedFetchPreferences() {
    // When
    sut.viewLoaded()

    // Then
    XCTAssertTrue(interactor.fetchPreferencesCalled)
  }

  func testViewLoadedShowLoadingView() {
    // When
    sut.viewLoaded()

    // Then
    XCTAssertTrue(router.showLoadingViewCalled)
  }

  func testFetchPreferencesFailsHideLoadingView() {
    // Given
    interactor.nextFetchPreferencesResult = .failure(BackendError(code: .other))

    // When
    sut.viewLoaded()

    // Then
    XCTAssertTrue(router.hideLoadingViewCalled)
  }

  func testFetchPreferencesFailsShowError() {
    // Given
    interactor.nextFetchPreferencesResult = .failure(BackendError(code: .other))

    // When
    sut.viewLoaded()

    // Then
    XCTAssertTrue(router.showErrorCalled)
  }

  func testFetchPreferencesSucceedHideLoadingView() {
    // Given
    interactor.nextFetchPreferencesResult = .success(notificationPreferences)

    // When
    sut.viewLoaded()

    // Then
    XCTAssertTrue(router.hideLoadingViewCalled)
  }

  func testFetchPreferencesSucceedPreferencesForPushAndEmailSetViewModelAppropriateChannels() {
    // Given
    interactor.nextFetchPreferencesResult = .success(notificationPreferences)

    // When
    sut.viewLoaded()

    // Then
    XCTAssertEqual(NotificationChannel.push, sut.viewModel.channel1.value)
    XCTAssertEqual(NotificationChannel.email, sut.viewModel.channel2.value)
  }

  func testFetchPreferencesSucceedPreferencesForPushAndSMSSetViewModelAppropriateChannels() {
    // Given
    let group = NotificationGroup(groupId: .atmWithdrawal, category: .cardActivity, state: .enabled,
                                  channel: NotificationGroup.Channel(push: true, sms: false))
    let preferences = NotificationPreferences(preferences: [group])
    interactor.nextFetchPreferencesResult = .success(preferences)

    // When
    sut.viewLoaded()

    // Then
    XCTAssertEqual(NotificationChannel.push, sut.viewModel.channel1.value)
    XCTAssertEqual(NotificationChannel.sms, sut.viewModel.channel2.value)
  }

  func testFetchPreferencesSucceedGroupNotificationsProperly() {
    // Given
    let group1 = NotificationGroup(groupId: .paymentSuccessful, category: .cardActivity, state: .disabled,
                                   channel: NotificationGroup.Channel(push: true, email: true))
    let group2 = NotificationGroup(groupId: .atmWithdrawal, category: .cardStatus, state: .enabled,
                                   channel: NotificationGroup.Channel(push: true, email: false))
    let preferences = NotificationPreferences(preferences: [group1, group2])
    interactor.nextFetchPreferencesResult = .success(preferences)

    // When
    sut.viewLoaded()

    // Then
    XCTAssertEqual(2, sut.viewModel.categories.value.count)
  }

  func testCloseTappedCalledCallRouter() {
    // When
    sut.closeTapped()

    // Then
    XCTAssertTrue(router.closeCalled)
  }

  func testViewLoadedDidUpdateRowCallInteractor() {
    // Given
    givenViewLoaded()
    let row = sut.viewModel.categories.value[0].rows[0]

    // When
    sut.didUpdateNotificationRow(row)

    // Then
    XCTAssertTrue(interactor.updatePreferencesCalled)
  }

  func testViewLoadedDidUpdateRowRemoveDisabledRows() {
    // Given
    givenViewLoaded()
    let row = sut.viewModel.categories.value[0].rows[0]

    // When
    sut.didUpdateNotificationRow(row)

    // Then
    for group in interactor.lastPreferencesToUpdate!.preferences {
      XCTAssertEqual(NotificationGroup.State.enabled, group.state)
    }
  }

  func testUpdatePreferencesFailsShowError() {
    // Given
    givenViewLoaded()
    let row = sut.viewModel.categories.value[0].rows[0]
    interactor.nextUpdatePreferencesResult = .failure(BackendError(code: .other))

    // When
    sut.didUpdateNotificationRow(row)

    // Then
    XCTAssertTrue(router.showErrorCalled)
  }

  func testUpdatePreferencesSucceedUpdateViewModel() {
    // Given
    givenViewLoaded()
    let viewModel = sut.viewModel
    let row = viewModel.categories.value[0].rows[0]
    interactor.nextUpdatePreferencesResult = .success(notificationPreferences)
    viewModel.categories.next([])

    // When
    sut.didUpdateNotificationRow(row)

    // Then
    XCTAssertTrue(viewModel.categories.value.count > 0)
  }

  private func givenViewLoaded() {
    interactor.nextFetchPreferencesResult = .success(notificationPreferences)
    sut.viewLoaded()
  }
}
