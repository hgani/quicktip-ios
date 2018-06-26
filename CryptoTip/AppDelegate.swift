import GaniLib

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        GHttp.instance.initialize(buildConfig: Build.instance, delegate: MyHttpDelegate())
        let app = GApp.instance.withNav(GNavigationController(rootViewController: SendScreen()))
//        let app = GApp.instance.withNav(GNavigationController(rootViewController: SendFormScreen(to: "RECIPIENT")))
//        let app = GApp.instance.withNav(GNavigationController(rootViewController: TransactionListScreen()))

        self.window = app.window
        
        
        if let url = launchOptions?[.url] as? URL {
            parseEthereumUri(url)
        }
        
        
        // Override point for customization after application launch.
        return true
    }

    private func parseEthereumUri(_ url: URL) -> Bool {
        var recipientAddress: String
        var chainId: Int = 1
        
        if Int(url.host!) == nil {
            recipientAddress = url.host!
        }
        else {
            chainId = Int(url.host!)!
            recipientAddress = url.user!
            
            if url.user?.range(of: "pay-") != nil {
                recipientAddress = String((url.user?.split(separator: "-")[1])!)
            }
        }
        
        let value = url.param(name: "value")
        let gasLimit = url.param(name: "gasLimit")
        let gasPrice = url.param(name: "gasPrice")
        let gas = url.param(name: "gas")
        
        print(url.path)
        print(recipientAddress)
        print(chainId)
        print(value)
        print(gasLimit)
        print(gasPrice)
        print(gas)
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

extension URL {
    func param(name: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == name })?.value
    }
}
