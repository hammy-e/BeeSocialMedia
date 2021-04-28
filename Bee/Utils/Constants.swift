//
//  Constants.swift
//  Bee
//
//  Created by Abraham Estrada on 4/13/21.
//

import UIKit
import Firebase

let YELLOWCOLOR  = #colorLiteral(red: 0.7095527053, green: 0.6537050009, blue: 0.1206735298, alpha: 1)

let COLLECTION_USERS = Firestore.firestore().collection("users")
let COLLECTION_FOLLOWERS = Firestore.firestore().collection("followers")
let COLLECTION_FOLLOWING = Firestore.firestore().collection("following")
let COLLECTION_POSTS = Firestore.firestore().collection("posts")
