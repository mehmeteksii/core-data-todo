//
//  ViewController.swift
//  toDoListtt
//
//  Created by Mehmet Ekşi on 5.09.2023.
//

import UIKit
import CoreData




class ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    var selectedKategoriler: Set<Kategori> = []

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let kategoriHucreID = "KategoriHucresiID"
    var kategoriListesi = [Kategori]()
    
    @IBOutlet weak var benimTableViewim: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "To Do List App"
        benimTableViewim.delegate = self
        benimTableViewim.dataSource = self
        verileriGetir()
        yükleIşaretlemeDurumu()
        
        

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        benimTableViewim.addGestureRecognizer(longPressGesture)
        
        // Do any additional setup after loading the view.
    }
    
    
    
    func yükleIşaretlemeDurumu() {
        if let işaretlenenKategoriIDs = UserDefaults.standard.array(forKey: "işaretlenenKategoriIDs") as? [String] {
            selectedKategoriler = Set<Kategori>()
            for işaretlenenID in işaretlenenKategoriIDs {
                if let uri = URL(string: işaretlenenID), let managedObjectID = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: uri), let işaretlenenKategori = try? context.existingObject(with: managedObjectID) as? Kategori {
                    selectedKategoriler.insert(işaretlenenKategori)
                }
            }
        }
    }

    func kaydetIşaretlemeDurumu() {
        let işaretlenenKategoriIDs = selectedKategoriler.map { $0.objectID.uriRepresentation().absoluteString }
        UserDefaults.standard.set(işaretlenenKategoriIDs, forKey: "işaretlenenKategoriIDs")
        UserDefaults.standard.synchronize()
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return kategoriListesi.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let hucre = tableView.dequeueReusableCell(withIdentifier: kategoriHucreID) as! AnaKategoriHucresi
            
            hucre.etiket.text = kategoriListesi[indexPath.row].isim
        
        
        if selectedKategoriler.contains(kategoriListesi[indexPath.row]) {
                hucre.accessoryType = .checkmark
            } else {
                hucre.accessoryType = .none
            }
            
            return hucre

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ogeViewControllerSegue" {
            if let indexPath = benimTableViewim.indexPathForSelectedRow {
                let selectedKategori = kategoriListesi[indexPath.row]
                if let ogeViewController = segue.destination as? OgeViewController {
                    ogeViewController.ustKategori = selectedKategori
                }
            }
        }
    }

    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Sil") { (action, view, completion) in
            // Silme işlemini burada gerçekleştirin
            self.context.delete(self.kategoriListesi[indexPath.row])
                    self.kategoriListesi.remove(at: indexPath.row)
                    self.benimTableViewim.reloadData()
                    
                    self.verileriKaydet()
                    self.verileriGetir()
          
        }
        
        
        
        let editAction = UIContextualAction(style: .normal, title: "Düzenle") { (action, view, completion) in
            print("dsdsfsdfsd")
            self.düzenleAlertGoster(hedefObje: self.kategoriListesi[indexPath.row])
        }
        
        
        // Silme işlemini gerçekleştirince gösterilecek simge ve arka plan rengi
        deleteAction.image = UIImage(systemName: "trash.fill")
        deleteAction.backgroundColor = .red
        
        // Silme işlemi haricinde başka işlemler eklemek isterseniz burada da ekleyebilirsiniz
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction,editAction])
        
        
        return configuration
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let secilenKategori = kategoriListesi[indexPath.row]
                let hedefVC = storyboard?.instantiateViewController(withIdentifier: "ogeViewControllerID") as! OgeViewController
                hedefVC.ustKategori = secilenKategori
                
                self.show(hedefVC, sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)

                
    }
    
    func düzenleAlertGoster(hedefObje: Kategori){
        var yaziAlanı = UITextField()
        
        let birAlert = UIAlertController(title: "Lütfen yeni görevinizi girin.", message: "", preferredStyle: .alert)
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
                let yeniKategori = Kategori(context: self.context)
                yeniKategori.isim = girilenText
                self.kategoriListesi.append(yeniKategori)
                
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
        self.benimTableViewim.reloadData()
    }
    
    func verileriGetir(){
        
        let talep:NSFetchRequest<Kategori> = Kategori.fetchRequest()
        
        do{
            kategoriListesi = try context.fetch(talep)
        }catch{
            print(error.localizedDescription)
        }
    }
    
   
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: benimTableViewim)
            if let indexPath = benimTableViewim.indexPathForRow(at: touchPoint) {
                let selectedKategori = kategoriListesi[indexPath.row]
                // Basılı tutulan hücreyi işaretleme listesine ekleyin veya kaldırın
                if selectedKategoriler.contains(selectedKategori) {
                    selectedKategoriler.remove(selectedKategori)
                } else {
                    selectedKategoriler.insert(selectedKategori)
                }
                benimTableViewim.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        kaydetIşaretlemeDurumu()
    }
    

    
}
