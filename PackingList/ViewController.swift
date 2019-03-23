

import UIKit

class ViewController: UIViewController {
    
    //MARK:- IB outlets
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var buttonMenu: UIButton!
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet weak var menuHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonMenuRightConstraint: NSLayoutConstraint!
    
    //TODO: Toggle Constraints
    @IBOutlet weak var titleCenterY: NSLayoutConstraint!
    @IBOutlet weak var titleCenterY_Open: NSLayoutConstraint!
    
    //MARK:- further class variables
    
    var slider: HorizontalItemList!
    var menuIsOpen = false
    var items: [Int] = [5, 6, 7]
    
    //MARK:- class methods
    
    @IBAction func toggleMenu(_ sender: AnyObject) {
        menuIsOpen = !menuIsOpen
        
        //TODO: Build your first constraint animation!
        titleLabel.text = menuIsOpen ? "Select Item to bring!" : "Packing List"
        self.view.layoutIfNeeded()
        
        titleCenterY.isActive = !menuIsOpen
        titleCenterY_Open.isActive = menuIsOpen
        
        //TODO: Search for a constraint and animate its multiplier
        
        titleLabel.superview?.constraints.forEach { constraint in
            //print("-> \(constraint.description)\n") //constraint checker
            if constraint.firstItem === titleLabel &&
                constraint.firstAttribute == .centerX {
                constraint.constant = menuIsOpen ? -90 : 0.0
                return
            }
            
            if constraint.identifier == "TitleCenterY" {
                constraint.isActive = false
                
                let newConstraint = NSLayoutConstraint(item: titleLabel,
                                                       attribute: .centerY,
                                                       relatedBy: .equal,
                                                       toItem: titleLabel.superview!,
                                                       attribute: .centerY,
                                                       multiplier: menuIsOpen ? 0.57 : 1.0,
                                                       constant: 5.0)
                newConstraint.identifier = "TitleCenterY"
                newConstraint.isActive = true
            }
        }
        
        menuHeightConstraint.constant = menuIsOpen ? 200.0 : 60.0
        buttonMenuRightConstraint.constant = menuIsOpen ? 30.0 : 8.0
        
        //TODO: Add Spring Animation: usingSpringWithDamping and initialSpringVelocity
        UIView.animate(withDuration: 1.0,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 10.0,
                       options: [],
                       animations: {
                        let angle: CGFloat =
                            self.menuIsOpen
                                ? .pi / 4
                                : 0.0
                        self.buttonMenu.transform = CGAffineTransform(rotationAngle: angle)
                        self.view.layoutIfNeeded()
        },
                       completion: nil)
    }
    
    func showItem(_ index: Int) {
        let imageView = makeImageView(index: index)
        view.addSubview(imageView)
        
        //TODO: Create constraints and set alignment
        
        // this set the imageView to horizontal center of View
        let conX = imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let conBottom = imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: imageView.frame.height)
        let conWidth = imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.33, constant: -50.0)
        let conHeight = imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
        
        NSLayoutConstraint.activate([conX, conBottom, conWidth, conHeight])
        self.view.layoutIfNeeded()
        
        //TODO: Animate In
        UIView.animate(withDuration: 1.0,
                       delay: 0.0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 10.0,
                       animations: {
                        conBottom.constant = -imageView.frame.size.height / 2
                        conWidth.constant = 0.0
                        self.view.layoutIfNeeded()
        }, completion: nil)
        
        //TODO: Animate Out v1
//        UIView.animate(withDuration: 0.67,
//                       delay: 2.0,
//                       animations: {
//                        conBottom.constant = -imageView.frame.size.height
//                        conWidth.constant = -50.0
//                        self.view.layoutIfNeeded()
//        }, completion: {_ in
//            imageView.removeFromSuperview()
//        })
        
        //TODO: Animate Out v2
        delay(seconds: 1.0) {
            UIView.transition(with: imageView,
                              duration: 1.0,
                              options: .transitionFlipFromBottom,
                              animations: {
                                //imageView.isHidden = true ->not working well with animations
            },
                              completion: {_ in
                                imageView.removeFromSuperview()
            })
        }
    }
    
    func transitionCloseMenu() {
        delay(seconds: 0.35, completion: {
            self.toggleMenu(self)
            
            //TODO: Add a view transition to the slider
            
            let titleBar = self.slider.superview!
            UIView.transition(with: titleBar,
                              duration: 0.75,
                              options: [.curveEaseOut,
                                        .transitionFlipFromBottom],
                              animations: {
                                self.slider.removeFromSuperview()
            },
                              completion: {_ in
                                titleBar.addSubview(self.slider)
            })
        })
    }
}

//////////////////////////////////////
//
//   Starter project code
//
//////////////////////////////////////

let itemTitles = ["Icecream money", "Great weather", "Beach ball", "Swim suit for him", "Swim suit for her", "Beach games", "Ironing board", "Cocktail mood", "Sunglasses", "Flip flops"]

// MARK:- View Controller

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func makeImageView(index: Int) -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: "summericons_100px_0\(index).png"))
        imageView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
        imageView.layer.cornerRadius = 5.0
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
    
    func makeSlider() {
        slider = HorizontalItemList(inView: view)
        slider.didSelectItem = {index in
            self.items.append(index)
            self.tableView.reloadData()
            self.transitionCloseMenu()
        }
        self.titleLabel.superview?.addSubview(slider)
    }
    
    // MARK: View Controller methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeSlider()
        self.tableView?.rowHeight = 54.0
    }
    
    // MARK: Table View methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        cell.accessoryType = .none
        cell.textLabel?.text = itemTitles[items[indexPath.row]]
        cell.imageView?.image = UIImage(named: "summericons_100px_0\(items[indexPath.row]).png")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showItem(items[indexPath.row])
    }
    
}
