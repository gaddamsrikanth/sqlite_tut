
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
    
    func addStudentData(_ studentInfo: AnyObject) -> Bool {
//        sharedInstance.database!.open()
//        let isInserted = sharedInstance.database!.executeUpdate("INSERT INTO student_info (Name, Marks) VALUES (?, ?)", withArgumentsIn: [studentInfo.Name, studentInfo.Marks])
//        sharedInstance.database!.close()
//        return isInserted
        return true

    }
   
    func updateStudentData(_ studentInfo: AnyObject) -> Bool {
//        sharedInstance.database!.open()
//        let isUpdated = sharedInstance.database!.executeUpdate("UPDATE student_info SET Name=?, Marks=? WHERE RollNo=?", withArgumentsIn: [studentInfo.Name, studentInfo.Marks, studentInfo.RollNo])
//        sharedInstance.database!.close()
//        return isUpdated
        return true
    }
    
    func deleteStudentData(_ studentInfo: AnyObject) -> Bool {
//        sharedInstance.database!.open()
//        let isDeleted = sharedInstance.database!.executeUpdate("DELETE FROM student_info WHERE RollNo=?", withArgumentsIn: [studentInfo.RollNo])
//        sharedInstance.database!.close()
//        return isDeleted
        return true

    }

    func getAllStudentData() -> NSMutableArray {
//        sharedInstance.database!.open()
//        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM student_info", withArgumentsIn: nil)
//        let marrStudentInfo : NSMutableArray = NSMutableArray()
//        if (resultSet != nil) {
//            while resultSet.next() {
//                let studentInfo : AnyObject = AnyObject()
//                studentInfo.RollNo = resultSet.string(forColumn: "RollNo")
//                studentInfo.Name = resultSet.string(forColumn: "Name")
//                studentInfo.Marks = resultSet.string(forColumn: "Marks")
//                marrStudentInfo.add(studentInfo)
//            }
//        }
//        sharedInstance.database!.close()
//        return marrStudentInfo
        return []
    }
}
