import UIKit

class AboutViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var appLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    

    override func viewDidLoad(){
        super.viewDidLoad()
        
        setAlpha()
        
        let appVersion  = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let appBuild    = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        versionLabel.text = "Ver \(appVersion ?? "-") (\(appBuild ?? "-"))"
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addBlur()
    }
    

    func setAlpha() {
        titleLabel.alpha    = 0
        iconImage.alpha     = 0
        appLabel.alpha      = 0
        versionLabel.alpha  = 0
    }
    
    
    //Adds blur to the uiview
    func addBlur(){
        if !UIAccessibility.isReduceTransparencyEnabled {
            view.backgroundColor = .clear
            
            let blurEffect     = UIBlurEffect(style: .systemChromeMaterial)
            let blurEffectView = UIVisualEffectView(effect: nil)
            let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
            let vibrancyView   = UIVisualEffectView(effect: nil)
            
            blurEffectView.frame            = self.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            vibrancyView.frame              = self.view.bounds
            vibrancyView.autoresizingMask   = [.flexibleWidth, .flexibleHeight]
            
            blurEffectView.tag = 3
            
            view.insertSubview(blurEffectView, at: 0)
            
            blurEffectView.contentView.addSubview(vibrancyView)
            
            UIView.animate(withDuration: 0.2, delay: 0.05){
                blurEffectView.effect = blurEffect
                vibrancyView.effect = vibrancyEffect
                
            }
            UIView.animate(withDuration: 0.2, delay: 0.3){
                self.titleLabel.alpha = 1

            }
            UIView.animate(withDuration: 0.2, delay: 0.5){
                self.iconImage.alpha = 1
                self.appLabel.alpha = 1
                self.versionLabel.alpha = 1
            }
        } else {
            view.backgroundColor = .clear
        }
        
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}


