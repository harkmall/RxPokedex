//
//  NetworkManager.swift
//  RxPokedex
//
//  Created by Mark Hall on 2019-07-21.
//  Copyright © 2019 Mark Hall. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import RxCocoa

struct PokemonDetails: Codable {
    var name: String
    var sprites: Sprites

    struct Sprites: Codable {
        var front: String

        enum CodingKeys: String, CodingKey {
            case front = "front_default"
        }
    }
}

struct PokemonListResponse: Codable {
    var count: Int
    var next: String
    var previous: String?
    var results: [PokemonItemResponse]
}

struct PokemonItemResponse: Codable {
    var name: String
    var url: String
}

enum PokemonErrors: Error {
    case error
}


struct NetworkManager {

    static var url = "https://pokeapi.co/api/v2/pokemon"

    typealias PokemonDetailsCompletion = (PokemonDetails?, Error?) -> Void

    static func getPokemon() -> Observable<PokemonListResponse> {
        return Observable.create { observer -> Disposable in
            Alamofire.request(url).responseData { response in
                guard let data = response.data else {
                    observer.onError(PokemonErrors.error)
                    return
                }
                do {
                    let response = try JSONDecoder().decode(PokemonListResponse.self, from: data)
                    url = response.next
                    observer.onNext(response)
                } catch {
                    observer.onError(PokemonErrors.error)
                }

            }
            return Disposables.create()
        }
    }

    static func getPokemonDetails(url: String) -> Observable<PokemonDetails> {
        return Observable.create { observer -> Disposable in
            Alamofire.request(url).responseData { response in
                guard let data = response.data else {
                    observer.onError(PokemonErrors.error)
                    return
                }
                do {
                    let response = try JSONDecoder().decode(PokemonDetails.self, from: data)
                    observer.onNext(response)
                } catch {
                    observer.onError(PokemonErrors.error)
                }
            }
            return Disposables.create()
        }
    }
}
