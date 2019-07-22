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

class ListViewModel {

    private let _dataSource = BehaviorRelay<[PokemonDetails]>(value: [])
    let dataSource: Driver<[PokemonDetails]>

    var currentData: [PokemonDetails] {
        return _dataSource.value
    }

    let nextPageRelay = BehaviorRelay<Int>(value: 0)

    let pageURL = BehaviorRelay<String?>(value: nil)

    let disposeBag = DisposeBag()

    init() {
        dataSource = _dataSource.asDriver()

        let pageObservable = pageURL.distinctUntilChanged()
            .flatMap { url -> Observable<String> in
                guard let urlString = url, !urlString.isEmpty else {
                    return Observable.empty()
                }
                return Observable.just(urlString)
        }

        let a = Observable.zip(pageObservable, nextPageRelay)
            .flatMap { NetworkManager.getPokemon(pageURL: $0.0) }

        _ = a.subscribe(onNext: {
            self.pageURL.accept($0.next)
        })

        a.map { $0.results }
            .flatMap { responseArray in
                Observable.combineLatest( responseArray.map{ item in
                    NetworkManager.getPokemonDetails(url: item.url)
                })
            }
            .asDriver(onErrorJustReturn: [])
            .drive(_dataSource)
            .disposed(by: disposeBag)
    }

}
