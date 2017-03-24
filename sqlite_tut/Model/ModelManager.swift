
import UIKit

let sharedInstance = ModelManager()

class ModelManager: NSObject {
    
    var database: FMDatabase? = nil

    class func getInstance() -> ModelManager
    {
        if(sharedInstance.database == nil)
        {
            sharedInstance.database = FMDatabase(path: Util.getPath("Student.sqlite"))
        }
        return sharedInstance
    }
    
    func addData(_ tblName: String,_ col:String,_ val:String) -> Bool {
        sharedInstance.database!.open()
        let isInserted = sharedInstance.database!.executeStatements("INSERT INTO \(tblName)(\(col)) VALUES(\(val))")
        sharedInstance.database!.close()
        return isInserted

    }
   
    func updateData(_ tblName: String,_ col:String,_ val:String) -> Bool {
        sharedInstance.database!.open()
        let isUpdated = sharedInstance.database!.executeStatements("UPDATE \(tblName) SET ")
        sharedInstance.database!.close()
        return isUpdated
    }
    
    func deleteData(_ tblName: String,_ col:String,_ val:String) -> Bool {
        sharedInstance.database!.open()
        let isDeleted = sharedInstance.database!.executeStatements("DELETE FROM student_info WHERE RollNo=?")
        sharedInstance.database!.close()
        return isDeleted
    }
    
    func getAllData(_ tblName: String) -> NSMutableArray {
        sharedInstance.database!.open()
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM \(tblName)", withArgumentsIn: nil)
        let marrStudentInfo : NSMutableArray = NSMutableArray()
        if (resultSet != nil) {
            while resultSet.next() {
                var dic = [String:Any]()
                for i in 0..<resultSet.columnCount() {
                    if resultSet.columnName(for: i) == "id" {
                        dic[resultSet.columnName(for: i)] = Int(resultSet.string(forColumn: resultSet.columnName(for: i)))
                    } else {
                        dic[resultSet.columnName(for: i)] = resultSet.string(forColumn: resultSet.columnName(for: i))
                    }
                }
                marrStudentInfo.add(dic)
            }
        }
        sharedInstance.database!.close()
        return marrStudentInfo
    }
    func getSpecificData(_ tblName: String,_ id: Int) -> [String:Any] {
        sharedInstance.database!.open()
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM \(tblName) WHERE id = \(id)", withArgumentsIn: nil)
//        let marrStudentInfo : NSMutableArray = NSMutableArray()
        var dic = [String:Any]()
        if (resultSet != nil) {
            while resultSet.next() {
                
                for i in 0..<resultSet.columnCount() {
                    if resultSet.columnName(for: i) == "id" {
                        dic[resultSet.columnName(for: i)] = Int(resultSet.string(forColumn: resultSet.columnName(for: i)))
                    } else {
                        dic[resultSet.columnName(for: i)] = resultSet.string(forColumn: resultSet.columnName(for: i))
                    }
                }
//                marrStudentInfo.add(dic)
            }
        }
        sharedInstance.database!.close()
        return dic
    }
}
