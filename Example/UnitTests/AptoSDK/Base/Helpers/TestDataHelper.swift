//
//  TestDataHelper.swift
//  UnitTests
//
//  Created by Fabio Cuomo on 26/10/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import SwiftyJSON
@testable import AptoSDK

func apiKey() -> String { "api_key" }
func userToken() -> String { "user_token" }
func anyApplicationId() -> String { "entity_XXXXXXXXXXXXXXXX" }
func anyMetadata() -> String { "any metadata" }
func anyAdditionalFields() -> [String : AnyObject] { ["field": "value" as AnyObject] }
func anyDesign() -> IssueCardDesign { ModelDataProvider.provider.design }
func anyCardProduct() -> CardProduct { ModelDataProvider.provider.cardProduct }
func anyCardId() -> String { "entity_XXXXXXXXXXXXXXXX" }

func makeIssueCard() -> (cardDetail: Card, json: JSON) {
    let card: JSON = [
        "type": "card",
        "account_id": "crd_5a34ba3d58ca34d2",
        "metadata": anyMetadata(),
        "state": "active",
        "ordered_status": "available",
        "last_four": "1234",
    ]
    return (ModelDataProvider.provider.cardWithMetadata, card)
}

func makeCardApplication() -> (cardApplication: CardApplication, json: JSON) {
    let card: JSON = [
        "type": "application",
        "application_type": "card",
        "application_data": [],
        "id": "entity_XXXXXXXXXXXXXXXX",
        "status": "approved",
        "create_time": "1601665324",
        "workflow_object_id": "entity_XXXXXXXXXXXXXXXX",
        "next_action": [
            "type": "action",
            "action_id": "entity_XXXXXXXXXXXXXXXX",
            "name": "collect_user_data",
            "order": 1,
            "status": 1,
            "editable_status": true,
            "action_type": "collect_user_data",
            "configuration": [
                "type": "action_collect_user_data_config",
                "required_datapoint_groups": []
            ],
            "labels": []
        ],
        "metadata": "string"
    ]
    return (ModelDataProvider.provider.cardApplication, card)
}

func makeSelectBalanceStoreResult() -> (selectBalance: SelectBalanceStoreResult, json: JSON) {
    
    let json: JSON = [
        "result": "valid",
        "error_code": 0
    ]
    return (ModelDataProvider.provider.selectBalanceStoreResult, json)
}
