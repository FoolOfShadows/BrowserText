//
//  NHAdmitModel.swift
//  BrowserText
//
//  Created by Fool on 2/24/20.
//  Copyright © 2020 Fool. All rights reserved.
//

import Foundation

enum NursingHome:String, CaseIterable {
    case MM = "Marshall Manor"
    case MMW = "Marshall Manor West"
    case HH = "Herritage House"
    case OWH = "Oakwood House"
    case RI = "Reunion Inn"
    
    static var nursingHomes:[String] {
        var tempCases = [String]()
        NursingHome.allCases.forEach {tempCases.append($0.rawValue)}
        return tempCases
    }
}

enum Condition:String, CaseIterable {
    case Stable
    case Critical
    case Guarded
    
    static var conditions:[String] {
        var tempCases = [String]()
        Condition.allCases.forEach {tempCases.append($0.rawValue)}
        return tempCases
    }
}

enum Vitals:String, CaseIterable {
    case Routine
    case WeeklyWt = "Weekly weight"
    case FallPrecautions = "Fall Precautions"
    
    static var vitals:[String] {
        var tempCases = [String]()
        Vitals.allCases.forEach {tempCases.append($0.rawValue)}
        return tempCases
    }
}

enum Lab:String, CaseIterable {
    case All = "CBC, CMP, Lipid, TSH"
    case DM = "HbA1c, UMalb"
    case Thy = "TSH, Free T4, Free T3"
    case HTN = "UMalb"
    
    static var labs:[String] {
        var tempCases = [String]()
        Lab.allCases.forEach {tempCases.append($0.rawValue)}
        return tempCases
    }
}


