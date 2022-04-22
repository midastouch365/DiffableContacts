//
//  ContentView.swift
//  Shared
//
//  Created by Oluwabusayo Adebayo on 4/19/22.
//

import SwiftUI

enum SectionType {
    case ceo, employees
}

class Contact: NSObject {
    let name: String
    var isFavorite = false
    
    init(name: String) {
        self.name = name
    }
}

class ContactSource: UITableViewDiffableDataSource<SectionType, Contact> {
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
}

struct DiffableContainer: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        UINavigationController(rootViewController: DiffableTableViewController(style: .insetGrouped))
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
    typealias UIViewControllerType = UIViewController
}

class DiffableTableViewController: UITableViewController {
    
    //UITableViewDiffableDataSource
    lazy var source: ContactSource = .init(tableView: self.tableView) { (_, indexPath, contact) -> UITableViewCell? in
        
        let cell = ContactCell(style: .default, reuseIdentifier: nil)
        cell.viewModel.name = contact.name
        cell.viewModel.isFavorite = contact.isFavorite
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            completion(true)
            
            var snapshot = self.source.snapshot()
            
            // Figure out the contact we need to delete
            guard let contact = self.source.itemIdentifier(for: indexPath) else {
                return
            }
            snapshot.deleteItems([contact])
            self.source.apply(snapshot)
        }
        let favoriteAction = UIContextualAction(style: .normal, title: "Favorite") { (action, view, completion) in
            completion(true)
            // tricky, tricky, tricky
            
            var snapshot = self.source.snapshot()
            
            guard let contact = self.source.itemIdentifier(for: indexPath) else {
                return
            }
            contact.isFavorite.toggle()
            
            snapshot.reloadItems([contact])
            self.source.apply(snapshot)
        }
        return .init(actions: [deleteAction, favoriteAction])
    }
    
    private func setupSource() {
        var snapshot = source.snapshot()
        snapshot.appendSections([.ceo, .employees])
        
        snapshot.appendItems([
            .init(name: "Elon Musk"),
            .init(name: "Tim Cook"),
            .init(name: "Oluwabusayo Adebayo")
        ], toSection: .ceo)
        
        snapshot.appendItems([
            .init(name: "Bill Gates"),
        ], toSection: .employees)

        source.apply(snapshot)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = section == 0 ? "CEO" : "EMPLOYEES"
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Contacts"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.rightBarButtonItem = .init(title: "Add Contact", style: .plain, target: self, action: #selector(handleAdd))
        
        setupSource()
    }
    
    @objc private func handleAdd() {
        let formView = ContactFormView { (image, name, sectionType) in
            self.dismiss(animated: true)
            
            var snapshot = self.source.snapshot()
            snapshot.appendItems([.init(name: name)], toSection: sectionType)
            self.source.apply(snapshot)
        }
        
        let hostingController = UIHostingController(rootView: formView)
        present(hostingController, animated: true)
    }
}

struct ContactFormView: View {
    
    var didAddContact: (UIImage, String, SectionType) -> () = { _,_,_   in }
        
    @State private var image: UIImage?

    @State private var name = ""
    
    @State private var sectionType = SectionType.ceo
        
    @State private var showImagePicker = false
    
    var body: some View {
        VStack(spacing: 10) {
            Button {
                showImagePicker.toggle()
            } label: {
                if let image = self.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .cornerRadius(5)
                        .frame(width: 100, height: 100, alignment: .center)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.blue, lineWidth: 3))
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 65))
                        .scaledToFill()
                        .cornerRadius(5)
                        .frame(width: 100, height: 100, alignment: .center)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.blue, lineWidth: 3))
                }
            }
            .padding(15)
            
            .sheet(isPresented: $showImagePicker, onDismiss: nil) {
                // Pick an image from the photo library:
                ImagePicker(sourceType: .photoLibrary, selectedImage: self.$image)

                //  If you wish to take a photo from camera instead:
                // ImagePicker(sourceType: .camera, selectedImage: self.$image)
            }
            
            TextField("Name", text: $name)
            
            Divider()
            
            Picker(selection: $sectionType, label: Text("DOESN'T MATTER")) {
                Text("CEO").tag(SectionType.ceo)
                Text("EMPLOYEES").tag(SectionType.employees)
            }
            .pickerStyle(SegmentedPickerStyle())
            
            Button(action: {
                // run a function/closure somehow
                self.didAddContact(self.image!, self.name, self.sectionType)
            }, label: {
                HStack {
                    Spacer()
                    Text("Add")
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding().background(Color.blue)
                .cornerRadius(5)
            })
            Spacer()
        }
        .padding()
    }
}

class ContactCell: UITableViewCell {
    
    let viewModel = ContactViewModel()
    
    lazy var row = ContactRowView(viewModel: viewModel)
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Setup my SwiftUI view somehow...
        let hostingController = UIHostingController(rootView: row)
       
        addSubview(hostingController.view)
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        hostingController.view.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        hostingController.view.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        hostingController.view.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
//        viewModel.name = "SOMETHING COMPLETELY NEW"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct ContactRowView: View {
    
    @ObservedObject var viewModel: ContactViewModel
        
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "person.fill")
                .font(.system(size: 34))
            Text(viewModel.name)
            Spacer()
            Image(systemName: viewModel.isFavorite ? "star.fill" : "star")
                .font(.system(size: 24))
        }
        .padding(20)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        DiffableContainer()
    }
}
