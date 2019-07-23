//
//  PokemonTableViewCell.swift
//  RxPokedex
//
//  Created by Mark Hall on 2019-07-21.
//  Copyright © 2019 Mark Hall. All rights reserved.
//

import UIKit
import AlamofireImage

class PokemonTableViewCell: UITableViewCell {

    @IBOutlet weak var pokemonImageView: UIImageView!
    @IBOutlet weak var label: UILabel!

    func setup(with pokemonDetails: PokemonDetails) {
        let imageURL = URL(string: pokemonDetails.sprites.front)!
        pokemonImageView.af_setImage(withURL: imageURL)

        label.text = pokemonDetails.name
    }

    override func prepareForReuse() {
        pokemonImageView.image = nil
    }
}
