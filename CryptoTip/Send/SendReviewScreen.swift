import GaniLib
import Eureka
//import web3swift
import KeychainSwift
import RNCryptor
import EthereumKit

class SendReviewScreen: GScreen {
    private let passwordField = GTextField().width(.matchParent).spec(.standard).secure(true).placeholder("Password")
    
    private let payload: TxPayload
    
    init(payload: TxPayload) {
        self.payload = payload
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Unsupported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Review"
        
        nav
            .color(bg: .navbarBg, text: .navbarText)
        
        self.paddings(t: 40, l: 20, b: 10, r: 20).done()
        
        container.addView(GLabel().text("To: \(payload.recipient)"))
        container.addView(GLabel().text("Amount: \(payload.amount) ETH"), top: 10)
        
        container.addView(passwordField, top: 30)
        container.addView(GButton().spec(.standard).title("Send").onClick { _ in
            self.executeTransaction()
        }, top: 10)

        onRefresh()
    }
    
    private func executeTransaction() {
        let encData = KeychainSwift().getData(Keys.dbPrivateKey) ?? Data()
        guard let decData = try? RNCryptor.decrypt(data: encData, withPassword: self.passwordField.text ?? ""), let key = String(data: decData, encoding: .utf8) else {
            self.launch.alert("Wrong password")
            return
        }
        
        let wallet = Wallet(network: Settings.instance.network(), privateKey: key, debugPrints: true)
        let address = wallet.generateAddress()
        
        Settings.instance.geth().getTransactionCount(of: address) { (result) in
            switch result {
            case .success(let nonce):
                self.submitTransaction(wallet: wallet, nonce: nonce)
                break
            case .failure(let error):
                self.launch.alert("Failed initiating transaction: \(error.localizedDescription)")
            }
        }
    }
    
    private func submitTransaction(wallet: Wallet, nonce: Int) {
        guard let wei = try? Converter.toWei(ether: Ether(payload.amount)) else {
            self.launch.alert("Invalid amount")
            return
        }
        
        let rawTx = RawTransaction(value: wei, to: self.payload.recipient, gasPrice: Converter.toWei(GWei: 10), gasLimit: 21000, nonce: nonce)
        guard let tx = try? wallet.sign(rawTransaction: rawTx) else {
            self.launch.alert("Failed signing transaction")
            return
        }
        
        Settings.instance.geth().sendRawTransaction(rawTransaction: tx) { transaction in
            switch transaction {
            case .success(let tx):
                self.launch.alert("Done. Transaction ID: \(tx.id)")
                break
            case .failure(let error):
                self.launch.alert("Failed submitting transaction: \(error.localizedDescription)")
            }
        }
    }
}

struct TxPayload {
    let recipient: String
    let amount: Double
}
