//
//  WeatherCell.swift
//  Weather
//
//  Created by Hari Bista on 10/14/21.
//

import UIKit

class WeatherCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func display(data: WeatherStatDisplayItem) {
        self.titleLabel.text = data.label
        self.valueLabel.text = data.value
    }

}
