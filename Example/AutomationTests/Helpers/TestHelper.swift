//
//  TestHelper.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 30/10/2017.
//

import AptoSDK
import Foundation
import SwiftyJSON

class TestHelper {
    let testProvisioner = TestProvisioner()
    var teams: [String: Team] = [:]
    var projects: [String: Project] = [:]
    var users: [String: AptoUser] = [:]

    // MARK: - Cache Cleaning

    func clean() {
        teams.forEach { _, team in
            self.deleteTeam(teamId: team.teamId)
        }

        teams = [:]

        projects.forEach { _, project in
            self.deleteProject(teamId: project.team?.teamId, projectId: project.projectId)
        }

        projects = [:]

        users.forEach { _, user in
            if let phoneDatapoint = user.userData.getDataPointsOf(type: .phoneNumber)?.first as? PhoneNumber {
                self.deleteUser(countryCode: phoneDatapoint.countryCode.value, phoneNumber: phoneDatapoint.phoneNumber.value)
            }
        }

        users = [:]
    } // end clean

    // MARK: - Provisioning

    func provisionTestTeam(name: String) -> Team? {
        let teamJSON = testProvisioner.provisionTeam(name: name)

        guard let teamData = teamJSON, let team = teamData.linkObject as? Team else {
            return nil
        }

        teams[team.teamId] = team

        return team
    } // end provisionTestTeam

    func provisionTestProject(team: Team?, name: String) -> Project? {
        guard let team = team else {
            return nil
        }

        let projectJSON = testProvisioner.provisionProject(teamId: team.teamId,
                                                           name: name)

        guard let projectData = projectJSON, let project = projectData.linkObject as? Project else {
            return nil
        }

        projects[project.projectId] = project

        return project
    } // end provisionTestTeam

    func provisionTestUser(teamKey: String? = nil,
                           projectKey: String? = nil,
                           countryCode: Int = 1,
                           phoneNumber: String = "9366669999",
                           email: String = "test@aptopayments.com",
                           verifiedPhone: Bool = false) -> AptoUser?
    {
        let userJSON = testProvisioner.provisionRandomTestUser(teamKey: teamKey,
                                                               projectKey: projectKey,
                                                               countryCode: countryCode,
                                                               phoneNumber: phoneNumber,
                                                               email: email,
                                                               verifiedPhone: verifiedPhone)

        guard let userData = userJSON, let user = userData.linkObject as? AptoUser else {
            return nil
        }

        users[user.userId] = user

        return user
    }

    // MARK: - Get Info

    func getKeys(teamId: String?, projectId: String?) -> [String: String]? {
        guard let teamId = teamId, let projectId = projectId else {
            return nil
        }

        let keysJSON = testProvisioner.getKeys(teamId: teamId, projectId: projectId)

        if let teamKey = keysJSON?["team_key"].string, let projectKey = keysJSON?["project_key"].string {
            return [
                "teamKey": teamKey,
                "projectKey": projectKey,
            ]
        }

        return nil
    } // end getKeys

    // MARK: - Deleting

    func deleteTeam(teamId: String?) {
        guard let teamId = teamId else {
            return
        }

        testProvisioner.deleteTeam(teamId: teamId)
    } // end deleteTeam

    func deleteProject(teamId: String?, projectId: String?) {
        guard let teamId = teamId, let projectId = projectId else {
            return
        }

        testProvisioner.deleteProject(teamId: teamId, projectId: projectId)
    } // end deleteProject

    func deleteUser(countryCode: Int?, phoneNumber: String?) {
        guard let countryCode = countryCode, let phoneNumber = phoneNumber else {
            return
        }

        testProvisioner.deleteUserWith(countryCode: countryCode, phoneNumber: phoneNumber)
    } // end deleteUser
} // end TestHelper
