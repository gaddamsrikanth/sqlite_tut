
import UIKit

let sharedInstance = ModelManager()

class ModelManager: NSObject {
    
    var database: FMDatabase? = nil

    class func getInstance() -> ModelManager
    {
        if(sharedInstance.database == nil)
        {
            sharedInstance.database = FMDatabase(path: Util.getPath("1.txt"))
        }
        return sharedInstance
    }
    
    func addData(_ tblName: String,_ columns: String,_ values : String) -> Bool {
        sharedInstance.database!.open()
        let val = String(values.characters.filter { !"\n".characters.contains($0) })

        let isInserted = sharedInstance.database!.executeUpdate("INSERT INTO \(tblName) (\(columns)) VALUES (\(val))")
        sharedInstance.database!.close()
            return isInserted
        
    }
   
    func updateData(_ studentInfo: AnyObject) -> Bool {
//        sharedInstance.database!.open()
//        let isUpdated = sharedInstance.database!.executeUpdate("UPDATE student_info SET Name=?, Marks=? WHERE RollNo=?", withArgumentsIn: [studentInfo.Name, studentInfo.Marks, studentInfo.RollNo])
//        sharedInstance.database!.close()
//        return isUpdated
        return true
    }
    
    func deleteData(_ studentInfo: AnyObject) -> Bool {
//        sharedInstance.database!.open()
//        let isDeleted = sharedInstance.database!.executeUpdate("DELETE FROM student_info WHERE RollNo=?", withArgumentsIn: [studentInfo.RollNo])
//        sharedInstance.database!.close()
//        return isDeleted
        return true

    }
    
    func getCommentData(_ tableName : String,_ postid : String) -> NSMutableArray {
        sharedInstance.database!.open()
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM \(tableName) where postId=\(postid)", withArgumentsIn: nil)
        let marrStudentInfo : NSMutableArray = NSMutableArray()
        if (resultSet != nil) {
            while resultSet.next() {
                var dic:[String:Any]? = [:]
                for i in 0..<resultSet.columnCount() {
                    dic?[String(resultSet.columnName(for: i))] = resultSet.string(forColumn: resultSet.columnName(for: i))
                }
                marrStudentInfo.add(dic!)
            }
        }
        sharedInstance.database!.close()
        return marrStudentInfo
    }

    func check(_ tableName: String,_ param : String,_ id: Int) -> Bool{
        sharedInstance.database!.open()
    
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM \(tableName) where \(param) = \(id)",withArgumentsIn: nil)
        if(resultSet.next() == true){
            sharedInstance.database!.close()
            return true
            
        }
        else {
            sharedInstance.database!.close()
            return false
        }
    }

    func getAllData(_ tableName : String) -> NSMutableArray {
        sharedInstance.database!.open()
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM \(tableName)", withArgumentsIn: nil)
        let marrStudentInfo : NSMutableArray = NSMutableArray()
        if (resultSet != nil) {
            while resultSet.next() {
                var dic:[String:Any]? = [:]
                for i in 0..<resultSet.columnCount() {
                    if resultSet.columnName(for : i).lowercased().contains("id"){
                        dic?[String(resultSet.columnName(for: i))] = Int(resultSet.string(forColumn: resultSet.columnName(for: i)))
                    } else {
                    dic?[String(resultSet.columnName(for: i))] = resultSet.string(forColumn: resultSet.columnName(for: i))
                    }
                }
                marrStudentInfo.add(dic!)
            }
        }
        sharedInstance.database!.close()
        return marrStudentInfo
    }
}
