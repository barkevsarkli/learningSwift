//
//  ViewController.swift
//  Dicee-iOS13
//
//  Created by Angela Yu on 11/06/2019.
//  Copyright © 2019 London App Brewery. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    @IBOutlet weak var dice_one: UIImageView!
    @IBOutlet weak var dice_two: UIImageView!
    
    let dice_array = [
        UIImage(imageLiteralResourceName: "DiceOne"), UIImage(imageLiteralResourceName: "DiceTwo"),
        UIImage(imageLiteralResourceName: "DiceThree"), UIImage(imageLiteralResourceName: "DiceFour"),
        UIImage(imageLiteralResourceName: "DiceFive"),UIImage(imageLiteralResourceName: "DiceSix"),
        ];
    
    @IBAction func buttonpressed(_ sender: UIButton)
    {
        dice_one.image = dice_array[Int.random(in: 0...5)];
        
        dice_two.image = dice_array[Int.random(in: 0...5)];
    }
}
