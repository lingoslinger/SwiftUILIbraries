//
//  LibraryPhoneNumberView.swift
//  SwiftUILibraries
//
//  Created by Allan Evans on 7/19/23.
//

import SwiftUI

struct LibraryPhoneNumberView: View {
    let library: Library
    
    var body: some View {
        let unwrappedPhone = library.phone ?? "Phone number not available"
        if unwrappedPhone == "Phone number not available" {
            Text(unwrappedPhone)
        } else {
            let formattedPhone = unwrappedPhone
            let removeChars: Set<Character> = [" ", "(", ")", "-"]
            let cleanNum = String(unwrappedPhone.filter {!removeChars.contains($0)})
            Link("Phone: \(formattedPhone)", destination: URL(string: "tel:\(cleanNum)")!)
        }
    }
}

#Preview {
    LibraryPhoneNumberView(library: previewLibrary)
}
