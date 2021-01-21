import SwiftUI
import SDWebImageSwiftUI //pod 'SDWebImageSwiftUI'

struct ContentView: View{
    @State var expand = true
    @State var search = "Japan" //ex) Japan : 바인딩으로 처리예정
   // @Binding var redisRsult: String
    @ObservedObject var RandomImages = getData()
    @State var page = 1
    @State var per_page = 1 //보여줄 이미지 개수
    @State var isSearching = false
    
    var body: some View{
        
        VStack{
            
            //Spacer()
            
           HStack{
               // 돋보기 클릭전
//                if !self.expand{
//                    VStack(alignment: .leading, spacing: 8) {
//
//                        Text("UnSplash")
//                            .font(.title)
//                            .fontWeight(.bold)
//                    }
//                    .foregroundColor(.black)
//                }
//                Spacer(minLength: 0)
//
//                Image(systemName: "magnifyingglass")
//                    .foregroundColor(.gray)
//                    .onTapGesture {
//
//                        withAnimation{
//                            //검색창 확장
//                            self.expand = true
//                        }
//                }
            
                // 돋보기 클릭시(확장상태)
                if self.expand{
                    
                    TextField("Search...", text: self.$search)//검색값 받기
                    // Displaying Close Button....
                    // Displaying search button when search txt is not empty
                    
                    if self.search != ""{//검색어 입력 받은 경우
                        
                        Button(action: {//find button
                            // Search Content
                            // deleting all existing data and displaying search data
                            self.RandomImages.Images.removeAll()
                            self.isSearching = true
                            self.page = 1 //default 1
                            self.SearchData()
                            
                        }) {
                            
                            Text("Find")
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                        }
                    }
                    
//                    Button(action: {//xmark button -> remove all
//
//                        withAnimation{
//
//                            self.expand = false
//                        }
//
//                        self.search = ""
//
//                        if self.isSearching{
//
//                            self.isSearching = false
//                            self.RandomImages.Images.removeAll()
//                            // updating home data
//                           // self.RandomImages.updateData()
//                        }
//                    }) {
//
//                        Image(systemName: "xmark")
//                            .font(.system(size: 15, weight: .bold))
//                            .foregroundColor(.black)
//                    }
//                    .padding(.leading,10)
                    
                    
                }
                
            }
            .padding(.top,UIApplication.shared.windows.first?.safeAreaInsets.top)
            .padding()
            .background(Color.white)
            
            if self.RandomImages.Images.isEmpty{
                //Data is loading or no data
                Spacer()
                
                if self.RandomImages.noresults{
                    Text("no results found")
                }
//                else{
//                    //Indicator() //로딩중..
//                }
                
                Spacer()
                
            }
            else{
                ScrollView(.vertical, showsIndicators: false) {
                            
                
                //Collection View...
                VStack(spacing: 15){
                    
                    ForEach(self.RandomImages.Images, id: \.self){ i in
                        
                        HStack(spacing: 20){
                            
                            ForEach(i){ j in
                                
                                AnimatedImage(url: URL(string: j.urls["regular"]!))
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: (UIScreen.main.bounds.width - 50) , height: 100)
                                    .cornerRadius(15)
                                
                            }
                        }
                    }
                    
                }
                .padding(.top)
            }
            }
            
        }
        .background(Color.black.opacity(0.07).edgesIgnoringSafeArea(.all))
        .edgesIgnoringSafeArea(.top)
        
    }
    
    
    func SearchData(){//사용자에게 입력 받은 값 처리하여 getData에 넘겨줌
        let key = "kg5CGnLPGSNn0Om49_wt2orc2bVvu6cmwbxl1idQhwM"
        let query = self.search.replacingOccurrences(of: " ", with: "%20")
        let url = "https://api.unsplash.com/search/photos/?page=\(self.page)&per_page=\(self.per_page)&query=\(query)&client_id=\(key)"
        
        self.RandomImages.SearchData(url: url)
        
    }
}


//Fetching Data
class getData : ObservableObject {
    //Going to create collection view
    
    @Published var Images: [[Photo]] = []
    @Published var noresults = false
    
    func SearchData(url: String){
        
        self.noresults = false
        
        let session = URLSession(configuration: .default)
        
        session.dataTask(with: URL(string: url)!) { (data, _, err) in
            
            if err != nil{
                print((err?.localizedDescription)!)
                return
            }
            
            //JSON decoding..
            do{
                let json = try JSONDecoder().decode(SearchPhoto.self, from: data!)
                
                for i in stride(from:0, to: json.results.count, by: 1){
                    var ArrayData : [Photo] = []
                    for j in i..<i+1{
                        if j < json.results.count{
                            ArrayData.append(json.results[j])
                        }
                    }
                    DispatchQueue.main.async{
                        self.Images.append(ArrayData)
                    }
                }
            }
            catch{
                print(error.localizedDescription)
            }
            
        }
        .resume()
    }
}

struct Photo : Identifiable, Decodable, Hashable {
    var id : String
    var urls : [String : String]
}

struct SearchPhoto : Decodable {
    
    var results : [Photo]
}

//struct Indicator : UIViewRepresentable{
//
//    func makeUIView(context: Context) -> UIActivityIndicatorView{
//        let view = UIActivityIndicatorView(style: .large)
//        view.startAnimating()
//        return view
//    }
//
//    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
//
//    }
//}
