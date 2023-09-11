//
//  OgeViewController.swift
//  toDoListtt
//
//  Created by Mehmet Ekşi on 5.09.2023.
//

import UIKit
import CoreData

class OgeViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    var selectedOgeler: Set<Oge> = []
    var ogeSayisi: Int = 0

    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var ogeListesi = [Oge]()
    var ogeHucreID = "OgeHucreID"
    
    @IBOutlet weak var benimTableView: UITableView!
    
    var ustKategori:Kategori!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        benimTableView.delegate = self
        benimTableView.dataSource = self
        verileriGetir()
        yükleIşaretlemeDurumu()
        
        if let ustKategori = self.ustKategori {
               title = ustKategori.isim
           } else {
               title = "Başlık Yok"
           }
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        benimTableView.addGestureRecognizer(longPressGesture)
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func yükleIşaretlemeDurumu() {
        if let işaretlenenOgeIDs = UserDefaults.standard.array(forKey: "işaretlenenOgeIDs") as? [String] {
            selectedOgeler = Set<Oge>()
            for işaretlenenID in işaretlenenOgeIDs {
                if let uri = URL(string: işaretlenenID), let managedObjectID = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: uri), let işaretlenenOge = try? context.existingObject(with: managedObjectID) as? Oge {
                    selectedOgeler.insert(işaretlenenOge)
                }
            }
        }
    }

    
    func kaydetIşaretlemeDurumu() {
        let işaretlenenOgeIDs = selectedOgeler.map { $0.objectID.uriRepresentation().absoluteString }
        UserDefaults.standard.set(işaretlenenOgeIDs, forKey: "işaretlenenOgeIDs")
        UserDefaults.standard.synchronize()
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ogeListesi.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let hucre = tableView.dequeueReusableCell(withIdentifier: ogeHucreID) as! OgeHucresi
        hucre.etiket.text = ogeListesi[indexPath.row].isim
        
        if selectedOgeler.contains(ogeListesi[indexPath.row]) {
                hucre.accessoryType = .checkmark
            } else {
                hucre.accessoryType = .none
            }
        
        return hucre
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Sil") { (action, view, completion) in
            // Silme işlemini burada gerçekleştirin
            self.context.delete(self.ogeListesi[indexPath.row])
            self.ogeListesi.remove(at: indexPath.row)
            self.benimTableView.reloadData()

            self.verileriKaydet()
            self.verileriGetir()
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Düzenle") { (action, view, completion) in
            print("dsdsfsdfsd")
            self.düzenleAlertGoster(hedefObje: self.ogeListesi[indexPath.row])
        }
        
        
        // Silme işlemini gerçekleştirince gösterilecek simge ve arka plan rengi
        deleteAction.image = UIImage(systemName: "trash.fill")
        deleteAction.backgroundColor = .red
        
        // Silme işlemi haricinde başka işlemler eklemek isterseniz burada da ekleyebilirsiniz
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction,editAction])
        return configuration
        
        
    }
    
    func düzenleAlertGoster(hedefObje: Oge){
        var yaziAlanı = UITextField()
        
        let birAlert = UIAlertController(title: "Lütfen yeni görevinizi girin", message: "", preferredStyle: .alert)
        let tamam = UIAlertAction(title: "Tamam", style: .default) { (_)  in
            hedefObje.isim = yaziAlanı.text
            self.verileriKaydet()
        }
        
        let vazgeç = UIAlertAction(title: "Vazgeç", style: .default, handler: nil)
        birAlert.addTextField { eklenenYaziAlani in
            yaziAlanı = eklenenYaziAlani
            yaziAlanı.text = hedefObje.isim
        }
        birAlert.addAction(vazgeç)
        birAlert.addAction(tamam)
        self.present(birAlert, animated: true, completion: nil )
    }
    
    
    
    @IBAction func ekleButonuTiklandi(_ sender: UIBarButtonItem) {
        var yazıGirisAlani = UITextField()
        
        let uyarıView = UIAlertController(title: "", message: "Lütfen eklemek istediğiniz görevi girin.", preferredStyle: .alert)
        
        let tamamAction = UIAlertAction(title: "Tamam", style: .default) { birAction in
            
            print("taöaö tıklandı")
            if let girilenText = yazıGirisAlani.text {
                let yeniOge = Oge(context: self.context)
                yeniOge.isim = girilenText
                yeniOge.ustKategori = self.ustKategori
                
                self.ogeListesi.append(yeniOge)
                
                self.verileriKaydet()
                self.verileriGetir()

            }
            
        }
        uyarıView.addAction(tamamAction)
        uyarıView.addTextField { birYaziAlani in
            yazıGirisAlani = birYaziAlani
        }
        self.present(uyarıView, animated: true, completion: nil)
    }
    
    
    func verileriKaydet(){
        do{
            try self.context.save()
        }catch{
            print(error.localizedDescription)
        }
        self.benimTableView.reloadData()
    }
    
    func verileriGetir(){
        
        let talep:NSFetchRequest<Oge> = Oge .fetchRequest()
        
        let birFiltre = NSPredicate(format: "ustKategori.isim MATCHES %@", self.ustKategori.isim!)
        
        talep.predicate = birFiltre
        do{
           ogeListesi = try context.fetch(talep)
            ogeSayisi = ogeListesi.count
        }catch{
            print(error.localizedDescription)
        }
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: benimTableView)
            if let indexPath = benimTableView.indexPathForRow(at: touchPoint) {
                let selectedOge = ogeListesi[indexPath.row]
                // Basılı tutulan hücreyi işaretleme listesine ekleyin veya kaldırın
                if selectedOgeler.contains(selectedOge) {
                    selectedOgeler.remove(selectedOge)
                } else {
                    selectedOgeler.insert(selectedOge)
                }
                benimTableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        kaydetIşaretlemeDurumu()
    }
    
}

