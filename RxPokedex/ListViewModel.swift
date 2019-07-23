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

class ListViewModel {

    private let _dataSource = BehaviorRelay<[PokemonDetails]>(value: [])
    let dataSource: Driver<[PokemonDetails]>

    let activityIndicator = ActivityIndicator()

    var currentData: [PokemonDetails] {
        return _dataSource.value
    }

    let nextPageRelay = BehaviorRelay<Int>(value: 0)

    let disposeBag = DisposeBag()

    init() {
        dataSource = _dataSource.asDriver()

        let activity = activityIndicator.asObservable().startWith(false)

        Observable.zip(nextPageRelay, activity)
            .flatMapLatest { (_, send) in
                send ? Observable.empty() : NetworkManager.getPokemon().trackActivity(self.activityIndicator)
            }
            .map { $0.results }
            .flatMap { responseArray in
                Observable.combineLatest( responseArray.map{ item in
                    NetworkManager.getPokemonDetails(url: item.url)
                })
            }
            .map { self.currentData + $0 }
            .asDriver(onErrorJustReturn: [])
            .drive(_dataSource)
            .disposed(by: disposeBag)
    }

}
