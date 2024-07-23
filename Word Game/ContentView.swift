//
//  ContentView.swift
//  Word Game
//
//  Created by Jesutofunmi Adewole on 14/02/2024.
//

import SwiftUI

struct ContentView: View {
    
    @State private var newWord = ""
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var wordScore = 0
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Enter yout word", text: $newWord)
                }
                Text("Score: \(wordScore)")
                    .fontWeight(.black)
                
                ForEach(usedWords, id: \.self) { word in
                    HStack {
                        Image(systemName: "\(word.count).circle.fill")
                            .foregroundColor(.red)
                        Text(word)
                    }
                }
            }
            .background(Color.green)
            .scrollContentBackground(.hidden)
            .navigationTitle(rootWord)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .onSubmit { addNewWord() }
            .onAppear(perform: { startGame() })
            .alert(errorTitle, isPresented: $showingError) { } message: { Text(errorMessage) }
            .toolbar {
                Button {
                    startGame()
                } label: {
                    Text("New word")
                        .foregroundColor(.indigo)
                }
            }
        }
    }
    
    func addNewWord() {
        let answerWord = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answerWord.count > 0 else { return }
        
        guard isReal(answerWord) else {
            showError(title: "Not a real word", message: "Enter a correct English word")
            return
        }
        
        guard isPossible(answerWord) else {
            showError(title: "Incorrect", message: "Try a different combination")
            return
        }
        
        guard isOriginal(answerWord) else {
            showError(title: "Get creative", message: "You've entered \(answerWord) already")
            return
        }
        
        guard answerWord.count > 2 else {
            showError(title: "Word is too short", message: "Enter words with at least three letters")
            return
        }
        
        guard answerWord != rootWord else {
            showError(title: "Word is same as root word", message: "Enter a different word")
            return
        }

        
        if isReal(answerWord) && isPossible(answerWord) && isOriginal(answerWord) {
            
            withAnimation {
                usedWords.insert(answerWord, at: 0)
            }
            newWord = ""
            wordScore += answerWord.count
        }
    }
    
    func isOriginal (_ word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isReal(_ word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func isPossible(_ word: String) -> Bool {
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
    
    func showError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            guard let startWords = try? String(contentsOf: startWordsURL) else { fatalError("Could not load start.txt from bundle") }
            let allWords = startWords.components(separatedBy: "\n")
            rootWord = allWords.randomElement() ?? "silkworm"
            newWord = ""
            wordScore = 0
            usedWords = [String]()
        }
    }
}

#Preview {
    ContentView()
}
