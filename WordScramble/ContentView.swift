//
//  ContentView.swift
//  WordScramble
//
//  Created by Alex Ciobanu on 12/27/21.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var score = 0
    @FocusState private var isNewWordFocused: Bool
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            List {
                Section() {
                    TextField("Enter your word", text: $newWord)
                        .autocapitalization(.none)
                        .focused($isNewWordFocused)
                }
                
                Section("Score") {
                    Text("\(score)")
                }
                
                Section(usedWords.count == 0 ? "" : "Guessed words"){
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .toolbar {
                Button("Restart") {
                    startGame()
                }
            }
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 2 else {
            wordError(title: "Word length too short", message: "Word must be longer than 2 characters!")
            return
        }
        
        guard answer == newWord else {
            wordError(title: "Word same as start word", message: "Cannot use same word as start word!")
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original!")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        
        newWord = ""
        keepScore(word: answer)
        isNewWordFocused = true
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                usedWords = [String]()
                newWord = ""
                score = 0
                isNewWordFocused = true
                return
            }
        }
        
        fatalError("Could not load start.txt from bundle.")
    }
    
    func keepScore(word: String) {
        score += word.count
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) ->  Bool {
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
        errorTitle = title
        errorMessage = message
        showingError = true
        newWord = ""
        isNewWordFocused = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
