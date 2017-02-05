//
//  Roster.swift
//  Chronos
//
//  Created by Carter Harwood on 2/4/17.
//  Copyright © 2017 Carter Harwood. All rights reserved.
//

import Foundation

struct Roster {
    let instructor: Instructor?
    let students: [Student]?
    
    init(withInstructor instructor:Instructor, andStudents students:[Student]) {
        // TODO - validate instructor not nil
        self.instructor = instructor
        // TODO - validate students not nil
        self.students = students
    }
}
