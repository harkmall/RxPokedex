//
//  ViewController.swift
//  RxPokedex
//
//  Created by Mark Hall on 2019-07-21.
//  Copyright © 2019 Mark Hall. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    let viewModel = ListViewModel()
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rx.contentOffset
            .distinctUntilChanged()
            .subscribe({ point in
            if point.element?.y ?? 0 >= (self.tableView.contentSize.height - self.tableView.frame.size.height) {
                self.viewModel.nextPageRelay.accept(0)
            }
        }).disposed(by: disposeBag)

        viewModel.dataSource.drive( tableView.rx.items(cellIdentifier: "PokemonCell", cellType: PokemonTableViewCell.self)) { row, pokemon, cell in
            cell.setup(with: pokemon)
        }.disposed(by: disposeBag)

        viewModel.nextPageRelay.accept(0)
    }
}

