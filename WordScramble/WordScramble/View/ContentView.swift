//
//  ContentView.swift
//  WordScramble
//
//  Created by Félix Tineo Ortega on 23/6/22.
//

import SwiftUI

struct ContentView: View {

    @ObservedObject private var viewModel = ScrambleViewModel()
    @FocusState private var newWordFocus: Bool
    
    var body: some View {
        NavigationView{
            VStack {
                List{
                    Section("Enter a word"){
                        TextField("New world", text: $viewModel.newWord)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .focused($newWordFocus)
                    }
                    if !viewModel.usedWord.isEmpty{
                    Section("Words entered"){
                        ForEach(viewModel.usedWord, id: \.self){ word in
                            HStack {
                                Image(systemName: "\(word.count).circle")
                                Text(word)
                            }
                        }                }
                    }
                }.onAppear{
                    viewModel.newGame()
                }.listStyle(.insetGrouped)
                    .navigationTitle(viewModel.rootWord)
                .toolbar {
                    Button("New Game"){
                        viewModel.newGame()
                    }
            }
                Text("Score: \(viewModel.score)")
            }
        }.alert(viewModel.titleErrorMessage, isPresented: $viewModel.isErrorMessageShown) {
            Button("Ok", role: .cancel){}
        } message: {
            Text(viewModel.errorMessage)
        }
        .onSubmit{
            viewModel.addWord()
            viewModel.newWord = ""
            newWordFocus = true
        }
        .onAppear{
            newWordFocus = true
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

enum WordScrambleError: Error {
    case fileNotFound, fileNotLoaded, emptyFile
}
