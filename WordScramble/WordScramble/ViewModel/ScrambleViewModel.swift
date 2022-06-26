//
//  ScrambleViewModel.swift
//  WordScramble
//
//  Created by Félix Tineo Ortega on 26/6/22.
//

import SwiftUI
import UIKit

class ScrambleViewModel: ObservableObject{
    @Published var usedWord: [String] = []
    @Published var newWord = ""
    @Published var rootWord = ""
    
    @Published var isErrorMessageShown = false
    @Published var titleErrorMessage = ""
    @Published var errorMessage = ""
    
    @Published var score: Int = 0
    
    func addWord(){
        let trimmedWord = newWord.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedWord.count > 0 else {
            showAlertMessage(title: "Wrong word", message: "You didn't insert any word")
            return
        }
        
        guard checkSpelling(word: trimmedWord) else {
            showAlertMessage(title: "Wrong word", message: "\(trimmedWord) does not exist")
            return
        }
        
        guard checkItIsPosible(rootWord: rootWord, word: trimmedWord) else {
            showAlertMessage(title: "Wrong word", message: "You can not form the word \(trimmedWord)")
            return
        }
        
        guard checkWordIsNotUsed(word: trimmedWord, words: usedWord) else {
            showAlertMessage(title: "Wrong word", message: "You already used the word \(trimmedWord)")
            return
        }
        
        withAnimation {
            usedWord.insert(trimmedWord, at: 0)
        }
        
        scorePoints(word: trimmedWord, words: usedWord)
        newWord = ""
        
    }
    
    func showAlertMessage(title: String, message: String){
        errorMessage = message
        titleErrorMessage = title
        isErrorMessageShown = true
    }
    
    func loadWords() throws -> [String]{
        
        var listOfWords: [String] = []
        
        guard let fileURL = Bundle.main.url(forResource: "words", withExtension: "txt") else {
            throw WordScrambleError.fileNotFound
        }
        guard let fileContent = try? String(contentsOf: fileURL) else {
            throw WordScrambleError.fileNotLoaded
        }
        
        guard !fileContent.isEmpty else {
            throw WordScrambleError.emptyFile
        }
        
        for word in fileContent.components(separatedBy: .newlines){
            if !word.isEmpty{
                listOfWords.append(word)
            }
        }
        
        return listOfWords
    }
    
    func newGame(){
        do {
            let words = try loadWords()
            usedWord = []
            score = 0
            let selectedWord = words.randomElement() ?? "bridge"
            rootWord = unsort(word: selectedWord)
            
        } catch {
            fatalError("Error when loading the words")
        }
    }
    
    func checkWordIsNotUsed(word: String, words:[String])->Bool{
        guard !words.contains(word) else {return false}
        return true
    }
    
    func checkSpelling(word: String)->Bool{
        let wordRange = NSRange(location: 0, length: word.utf16.count)
        let result = UITextChecker().rangeOfMisspelledWord(in: word, range: wordRange, startingAt: 0, wrap: false, language: "en")
        guard result == NSRange(location: NSNotFound, length: 0) else {return false}
        return true
    }

    func checkItIsPosible(rootWord:String, word: String)->Bool{
        var auxiliaryWord = rootWord
        for letter in word {
            if let index = auxiliaryWord.firstIndex(of: letter){
                auxiliaryWord.remove(at: index)
            } else {
                return false
            }
        }
        return true
    }


    func unsort(word: String)->String{
        var result:[String.Element] = []
        var temporaryWord = Array(word)
        var randomIndex = 0
        
        while !temporaryWord.isEmpty{
            randomIndex = Int.random(in: 0..<temporaryWord.count)
            let randomLetter = temporaryWord[randomIndex]
            temporaryWord.remove(at: randomIndex)
            result.append(randomLetter)
        }
        
        return String(result)
    }
    
    func scorePoints(word:String, words:[String]){
        score += words.count * word.count
    }
}
