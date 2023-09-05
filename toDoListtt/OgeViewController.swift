//
//  OgeViewController.swift
//  toDoListtt
//
//  Created by Mehmet Ekşi on 5.09.2023.
//

import UIKit
import CoreData

class OgeViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    

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
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ogeListesi.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let hucre = tableView.dequeueReusableCell(withIdentifier: ogeHucreID) as! OgeHucresi
        hucre.etiket.text = ogeListesi[indexPath.row].isim
        return hucre
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Sil") { (action, view, completion) in
            // Silme işlemini burada gerçekleştirin
            self.context.delete(self.ogeListesi[indexPath.row])
            self.ogeListesi.remove(at: indexPath.row)
            self.benimTableView.reloadData()

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
        
        let birAlert = UIAlertController(title: "Yeni degeri giriniz", message: "", preferredStyle: .alert)
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
        
        let uyarıView = UIAlertController(title: "", message: "Eklemek istediğinix veriyi giriniz", preferredStyle: .alert)
        
        let tamamAction = UIAlertAction(title: "Tamam", style: .default) { birAction in
            
            print("taöaö tıklandı")
            if let girilenText = yazıGirisAlani.text {
                let yeniOge = Oge(context: self.context)
                yeniOge.isim = girilenText
                yeniOge.ustKategori = self.ustKategori
                
                self.ogeListesi.append(yeniOge)
                
                self.verileriKaydet()
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
        }catch{
            print(error.localizedDescription)
        }
    }
}

