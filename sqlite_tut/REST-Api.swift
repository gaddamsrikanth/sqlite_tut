
import Foundation
import UIKit
class Calling_Status{
    var Status:Bool
    var Message:String
    var Request_Url:String
    init(Status:Bool,Message:String,Request_Url:String){
        self.Status = Status
        self.Message = Message
        self.Request_Url = Request_Url
    }
}
class server_API {
    
    static let sharedObject = server_API()
    
    let Base_url = "http://jsonplaceholder.typicode.com/"
    
    let int_gone_msg = "You are disconnected from the internet.".capitalized
    
    func requestFor_NSMutableDictionary(Str_Request_Url:String , Request_parameter:[String: String]? , Request_parameter_Images:[String: UIImage]? ,status: @escaping (_ result: Calling_Status) -> Void , response_Dictionary: @escaping (_ results: NSMutableDictionary) -> Void , response_Array: @escaping (_ results: NSMutableArray) -> Void,isTokenEmbeded:Bool){
        let myurl = NSURL(string: "\(Base_url)\(Str_Request_Url)")
        let obj_of_status = Calling_Status(Status: false, Message: "Request Failed",Request_Url: "\(Base_url)\(Str_Request_Url)")
        print(myurl!)
        let req = NSMutableURLRequest(url: myurl! as URL)
        if(isTokenEmbeded == false){
            
        }else{
//            req.setValue(AppDelegate.token , forHTTPHeaderField: "Authorization")
        }
        var QuaryString = ""
        
        if Request_parameter_Images != nil {
            req.httpMethod = "POST"
            let boundary = generateBoundaryString()
            req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            var key_name = ""
            var image_date = [UIImage]()
            for (key, value) in Request_parameter_Images! {
                let imageData = UIImageJPEGRepresentation(value, 1)
                if imageData != nil{
                    if(key.contains("product_image")){
                        key_name="product_image"
                        image_date.append(value)
                    }else{
                        req.httpBody = self.createBodyWithParameters(parameters: Request_parameter, filename: key, filePathKey: key, imageDataKey: imageData! as NSData, boundary: boundary) as Data
                    }
                }
            }
            if key_name != ""
            {
                req.httpBody = self.createBodyWithParameters_arr(parameters: Request_parameter, filename: key_name, filePathKey: key_name, imageDataKey: image_date, boundary: boundary) as Data
            }
        }
        else{
            if Request_parameter  != nil {
                req.httpMethod = "POST"
                _ = generateBoundaryString()
                
                for (key, value) in Request_parameter!
                {
                    QuaryString = "\(QuaryString)\(key)=\(value)&"
                }
                req.httpBody = QuaryString.data(using: String.Encoding.utf8)
                
            }
        }
        
        
        
        
        let task = URLSession.shared.dataTask(with: req as URLRequest){
            data,res,err in
            if(err != nil)
            {
                if err?._code == -1004{
                    obj_of_status.Message = "Could't create connection with the server.".capitalized
                    status(obj_of_status)
                    return
                }else if err?._code == -1202{
                    obj_of_status.Message = "Could't create connection with the server.".capitalized
                    status(obj_of_status)
                    return
                }
                obj_of_status.Message = "\(err)"
                status(obj_of_status)
                return
            }
            
            if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_9_3{
            do {
                if let json: NSMutableDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSMutableDictionary
                {
                    obj_of_status.Message = "Success get Response.".capitalized
                    status(obj_of_status)
                    response_Dictionary(json)
                    return
                }else{
                    if let json: NSMutableArray = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSMutableArray
                    {
                        obj_of_status.Message = "Success get Response.".capitalized
                        status(obj_of_status)
                        response_Array(json)
                        return
                    }else{
                        if (res != nil) {
                            obj_of_status.Message = "\(((res as? HTTPURLResponse)?.statusCode)!)"
                        }
                        status(obj_of_status)
                        return
                    }
                }
            } catch let error as NSError {
                obj_of_status.Message = "\(error.localizedDescription)"
                if (res != nil) {
                    obj_of_status.Message = "\(((res as? HTTPURLResponse)?.statusCode)!)"
                }
                status(obj_of_status)
                return
            }
            }else{
                do {
                    if let json: NSMutableDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? NSMutableDictionary
                    {
                        obj_of_status.Message = "Success get Response.".capitalized
                        status(obj_of_status)
                        response_Dictionary(json)
                        return
                    }else{
                        if let json: NSMutableArray = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? NSMutableArray
                        {
                            obj_of_status.Message = "Success get Response.".capitalized
                            status(obj_of_status)
                            response_Array(json)
                            return
                        }else{
                            if (res != nil) {
                                obj_of_status.Message = "\(((res as? HTTPURLResponse)?.statusCode)!)"
                            }
                            status(obj_of_status)
                            return
                        }
                    }
                } catch let error as NSError {
                    obj_of_status.Message = "\(error.localizedDescription)"
                    if (res != nil) {
                        obj_of_status.Message = "\(((res as? HTTPURLResponse)?.statusCode)!)"
                    }
                    status(obj_of_status)
                    return
                }
            }
        }
        task.resume()
    }
    
    
    private func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    private func createBodyWithParameters(parameters: [String: String]?,filename:String , filePathKey: String?, imageDataKey: NSData, boundary: String) -> NSData {
        let body = NSMutableData();
        if parameters != nil {
            for (key, value) in parameters! {
                body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: String.Encoding.utf8)!)
                body.append("\(value)\r\n".data(using: String.Encoding.utf8)!)
            }
        }
        let mimetype = "image/jpg"
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\("profile_image")\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(imageDataKey as Data)
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        return body
    }
    private func createBodyWithParameters_arr(parameters: [String: String]?,filename:String , filePathKey: String?, imageDataKey: [UIImage], boundary: String) -> NSData {
        let body = NSMutableData();
        if parameters != nil {
            for (key, value) in parameters! {
                body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: String.Encoding.utf8)!)
                body.append("\(value)\r\n".data(using: String.Encoding.utf8)!)
            }
        }
        for i in 0  ..< imageDataKey.count {
            let mimetype = "image/jpg"
            body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\("profile_image")\"\r\n".data(using: String.Encoding.utf8)!)
            body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
            let imageData = UIImageJPEGRepresentation(imageDataKey[i], 1)
            body.append(imageData!)
            body.append("\r\n".data(using: String.Encoding.utf8)!)
            body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        }
        return body
    }
    
    private func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func requestFor_Upload_image_With_Data_And_Progress(delegate: URLSessionDelegate,Str_Request_Url:String , Request_parameter:[String: String]? , Request_parameter_Images:[String: UIImage]? , sessionDescription:String? , Compression_Ratio:Float?){
        
        DispatchQueue.global().async {
            let myurl = NSURL(string: "\(self.Base_url)\(Str_Request_Url)")
            print(myurl!)
            let req = NSMutableURLRequest(url: myurl! as URL)
            if Request_parameter_Images != nil {
                req.httpMethod = "POST"
                let boundary = self.generateBoundaryString()
                req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                for (key, value) in Request_parameter_Images! {
                    var imageData:NSData?
                    if Compression_Ratio != nil{
                        if Compression_Ratio! >= Float(100){
                            imageData = UIImageJPEGRepresentation(value, 1) as NSData?
                        }else if Compression_Ratio! < Float(10){
                            imageData = UIImageJPEGRepresentation(self.resizeImage(image: value, newWidth: (value.size.width * 10) / 100), 1) as NSData?
                        }else{
                            imageData = UIImageJPEGRepresentation(self.resizeImage(image: value, newWidth: (value.size.width * CGFloat(Compression_Ratio!)) / 100), 1) as NSData?
                        }
                    }else{
                        imageData = UIImageJPEGRepresentation(value, 1) as NSData?
                    }
                    if imageData != nil{
                        req.httpBody = self.createBodyWithParameters(parameters: Request_parameter, filename: key, filePathKey: key, imageDataKey: imageData!, boundary: boundary) as Data
                        break
                    }
                }
            }else{
                if Request_parameter != nil {
                    req.httpMethod = "POST"
                    var QuaryString = ""
                    for (key, value) in Request_parameter! {
                        QuaryString = "\(QuaryString)\(key)=\(value)&"
                    }
                    req.httpBody = QuaryString.data(using: String.Encoding.utf8)
                }
            }
            
            let configuration = URLSessionConfiguration.default
            let session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: OperationQueue.current)
            session.sessionDescription = sessionDescription
            let task = session.uploadTask(with: req as URLRequest, from: req.httpBody!)
            task.resume()
        }
        }
    
}
