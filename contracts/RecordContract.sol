pragma solidity 0.8.2;
pragma experimental ABIEncoderV2;

contract RecordContract {
    enum RecordStatus {
        PENDING,
        COMPLETED,
        DECLINED
    }

    struct Record {
        string encryptedID;
        string dataHash;
        address issuerDoctorAddr;
        address patientAddr;
        uint timestamp;
        RecordStatus recordStatus;
    }

    mapping(string => Record) public recordList;

    event RecordCreated(
        string encryptedID,
        string dataHash,
        address issuerDoctorAddr,
        uint timestamp,
        RecordStatus recordStatus,
        address patientAddr
    );

    function createRecord(
        string memory _encryptedID,
        string memory _dataHash,
        address _issuerDoctorAddr,
        address _patientAddr
    ) public {
        // require(isDoctor[_issuerDoctorAddr]);
        // require(isPatient[_patientAddr]);

        uint timestamp = block.timestamp;
        RecordStatus recordStatus = RecordStatus.PENDING;

        recordList[_encryptedID].encryptedID = _encryptedID;
        recordList[_encryptedID].dataHash = _dataHash;
        recordList[_encryptedID].issuerDoctorAddr = _issuerDoctorAddr;
        recordList[_encryptedID].patientAddr = _patientAddr;
        recordList[_encryptedID].timestamp = timestamp;
        recordList[_encryptedID].recordStatus = recordStatus;

        // patientList[_patientAddr].recordList.push(_encryptedID);

        emit RecordCreated(
            _encryptedID,
            _dataHash,
            _issuerDoctorAddr,
            timestamp,
            recordStatus,
            _patientAddr
        );
    }

    function editRecord(
        string memory _encryptedID,
        string memory _dataHash,
        RecordStatus _recordStatus
    ) public {
        uint timestamp = block.timestamp;
        recordList[_encryptedID].encryptedID = _encryptedID;
        recordList[_encryptedID].dataHash = _dataHash;
        recordList[_encryptedID].timestamp = timestamp;
        recordList[_encryptedID].recordStatus = _recordStatus;
    }

    function getRecordDetails(
        string memory _encryptedID
    ) public view returns (Record memory) {
        return recordList[_encryptedID];
    }

    function removeRecord(string memory _encryptedID) public {
        delete recordList[_encryptedID];
    }
}
