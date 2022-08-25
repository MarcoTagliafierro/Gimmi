//
//  Errors.swift
//  Gimmi
//
//  Created by Marco Tagliafierro on 09/12/21.
//

import Foundation

struct GenericError: Error {
    let description = "Generic Error"
}

struct ConnectionError: Error {
    let description = "Generic Error"
}

struct ConversionError: Error {
    let description = "Wrongly formatted data"
}
