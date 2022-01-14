//
// VoIPPresenter.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 18/06/2019.
//

import AptoSDK
import ReactiveKit

class VoIPPresenter: VoIPPresenterProtocol {
    private let voIPCaller: VoIPCallProtocol
    private var timer: Timer?
    let viewModel = VoIPViewModel()
    var router: VoIPModuleProtocol?
    var interactor: VoIPInteractorProtocol?
    var analyticsManager: AnalyticsServiceProtocol?

    init(voIPCaller: VoIPCallProtocol) {
        self.voIPCaller = voIPCaller
    }

    deinit {
        timer?.invalidate()
    }

    func viewLoaded() {
        analyticsManager?.track(event: .voIPCallStarted)
        viewModel.callState.send(.starting)
        interactor?.fetchVoIPToken { [weak self] result in
            switch result {
            case let .failure(error):
                self?.viewModel.error.send(error)
            case let .success(voIpToken):
                self?.startCall(token: voIpToken)
            }
        }
    }

    func muteCallTapped() {
        voIPCaller.isMuted = true
    }

    func unmuteCallTapped() {
        voIPCaller.isMuted = false
    }

    func hangupCallTapped() {
        analyticsManager?.track(event: .voIPCallEnded, properties: ["time_elapsed": voIPCaller.timeElapsed as Any])
        voIPCaller.disconnect()
        viewModel.callState.send(.finished)
        timer?.invalidate()
        router?.callFinished()
    }

    func keyboardDigitTapped(_ digit: String) {
        voIPCaller.sendDigits(VoIPDigits(digits: digit))
    }

    private func startCall(token: VoIPToken) {
        voIPCaller.call(token) { [weak self] result in
            switch result {
            case let .failure(error):
                self?.analyticsManager?.track(event: .voIPCallFails)
                self?.viewModel.error.send(error)
            case .success:
                self?.viewModel.callState.send(.established)
                self?.viewModel.timeElapsed.send("00:00")
                let timer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
                    self?.updateTimeElapsed()
                }
                self?.timer = timer
                RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
            }
        }
    }

    private func updateTimeElapsed() {
        let interval = Int(voIPCaller.timeElapsed)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        viewModel.timeElapsed.send(String(format: "%02d:%02d", minutes, seconds))
    }
}
