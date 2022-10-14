//
//  ContentView.swift
//  WordScramble-HWS-P5
//
//  Created by Ade Dwi Prayitno on 14/10/22.
//

import SwiftUI

struct ContentView: View {
    @State private var useWords = [String]()
    @State private var rootWord: String = ""
    @State private var newWord: String = ""
    
    @State private var errorTitle: String = ""
    @State private var errorMessage: String = ""
    @State private var showingError: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.none)
                }
                
                Section {
                    ForEach(useWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle.fill")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else {return}
        
        guard isOriginal(word: answer) else {
            wordError(title: "Kata telah ada", message: "Coba Masukkan kata lain")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Kata tidak memungkinkan", message: "Anda tidak bisa menggunakan kata dari \(rootWord)")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Inputan bukan kata yang valid dalam bahasa inggris", message: "Tidak bisa memasukkan kata selain bahasa inggris atau kata yang tidak bermakna!")
            return
        }
        
        withAnimation {
            useWords.insert(answer, at: 0)
        }
        newWord.removeAll()
    }
    
    func startGame() {
        if let startWordURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordURL){
                let allWords = startWords.components(separatedBy: .newlines)
                rootWord = allWords.randomElement() ?? "silkworm"
                
                return
            }
        }
        fatalError("Tidak berhasil menemukan start.txt pada app bundle")
    }
    
    func isOriginal(word: String) -> Bool {
        !useWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorMessage = message
        errorTitle = title
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
