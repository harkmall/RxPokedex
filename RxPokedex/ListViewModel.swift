//
//  ListViewModel.swift
//  RxPokedex
//
//  Created by Mark Hall on 2019-07-21.
//  Copyright © 2019 Mark Hall. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxSwiftUtilities

struct ListViewModel {

    let dataSource: Driver<[PokemonDetails]>

    let nextPageRelay = PublishRelay<Void>()

    init() {
        let activityIndicator = ActivityIndicator()
        let activity = activityIndicator.asObservable()
            .startWith(false)

        dataSource = nextPageRelay
            .withLatestFrom(activity)
            .filter { !$0 }
            .flatMapLatest { _ in
                NetworkManager.getPokemon()
                    .map { $0.results }
                    .flatMapLatest { responseArray in
                        Observable.combineLatest( responseArray.map { item in
                            NetworkManager.getPokemonDetails(url: item.url)
                        })
                    }
                    .trackActivity(activityIndicator)
            }
            .scan([], accumulator: { $0 + $1 })
            .asDriver(onErrorJustReturn: [])
    }

}
