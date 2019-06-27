//
//  PatientData.swift
//  BrowserText
//
//  Created by Fool on 6/11/19.
//  Copyright © 2019 Fool. All rights reserved.
//

import Cocoa

public struct PatientDataProfile {
    var firstName = String()
    var middleName = String()
    var lastName = String()
    var dob = String()
    var street = String()
    var city = String()
    var state = "TX"
    var zip = String()
    var mobilePhone = String()
    var homePhone = String()
    var email = String()
    var insurances = [(String, String)]()
    
    var fullName:String {
        let nameArray:[String] = [self.firstName, self.middleName, self.lastName]
        let cleanArray = nameArray.filter {!$0.isEmpty}
        return cleanArray.joined(separator: " ")
    }
    var fullAddress:String {
        return """
\(street)
\(city), \(state)  \(zip)
"""
    }
    var age:String {
        let now = Date()
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d/yyyy"
        //print("DOB: \(self.dob)")
        let birth:Date = dateFormatter.date(from: self.dob)!
        let ageComponents = calendar.dateComponents([.year], from: birth, to: now)
        return String(ageComponents.year!)
    }
}
