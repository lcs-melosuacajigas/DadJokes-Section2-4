//
//  ContentView.swift
//  DadJokes
//
//  Created by Russell Gordon on 2022-02-21.
//

import SwiftUI

struct ContentView: View {
    
    // MARK: Stored properties
    @State var currentJoke: DadJoke = DadJoke(id: "",
                                       joke: "Knock, knock...",
                                       status: 0)
    
    // MARK: Computed properties
    var body: some View {
        VStack {
            
            Text(currentJoke.joke)
                .font(.title)
                .multilineTextAlignment(.leading)
                .padding(30)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.primary, lineWidth: 4)
                )
                .padding(10)
            
            Image(systemName: "heart.circle")
                .font(.largeTitle)
            
            Button(action: {
                print("I've been pressed.")
                
                // It must be called within a Task structure
                // so that it runs asynchronously
                // NOTE: Button's action normally expects synchronous code
                
                Task {
                    await loadNewJoke()
                }
                
               
                
                
            }, label: {
                Text("Another one!")
            })
                .buttonStyle(.bordered)
            
            HStack {
                Text("Favourites")
                    .bold()
                
                Spacer()
            }
            
            List {
                Text("Which side of the chicken has more feathers? The outside.")
                Text("Why did the Clydesdale give the pony a glass of water? Because he was a little horse!")
                Text("The great thing about stationery shops is they're always in the same place...")
            }
            
            Spacer()
                        
        }
        // When the app opens, get a new joke from the web service
        .task {
            
            // We "call" the loadNewJoke function to tell the computer to get that new joke
            // By typing await we are acknowledging that we know this function may run at the same time as other tasks in the app
            await loadNewJoke()
            
            
            // DEBUG
            print("Have just attempted to load a new joke")
        }
        .navigationTitle("icanhazdadjoke?")
        .padding()
    }
    
    //MARK: Functions
    // This function loads a new joke by talking to an endpoint in the web
    // We must mark the funtion as "async" so that it can be asynchronously which means it might run at the same time as other tasks
    // This is the function definition
    func loadNewJoke() async  {
        // Assemble the URL that points to the endpoint
        let url = URL(string: "https://icanhazdadjoke.com/")!
        
        // Define the type of data we want from the endpoint
        // Configure the request to the web site
        var request = URLRequest(url: url)
        // Ask for JSON data
        request.setValue("application/json",
                         forHTTPHeaderField: "Accept")
        
        // Start a session to interact (talk with) the endpoint
        let urlSession = URLSession.shared
        
        // Try to fetch a new joke
        // It might not work, so we use a do-catch block
        do {
            
            // Get the raw data from the endpoint
            let (data, _) = try await urlSession.data(for: request)
            
            // Attempt to decode the raw data into a Swift structure
            // Takes what is in "data" and tries to put it into "currentJoke"
            //                                 DATA TYPE TO DECODE TO
            //                                         |
            //                                         V
            currentJoke = try JSONDecoder().decode(DadJoke.self, from: data)
            
        } catch {
            print("Could not retrieve or decode the JSON from endpoint.")
            // Print the contents of the "error" constant that the do-catch block
            // populates
            print(error)
        }

    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ContentView()
        }
    }
}
