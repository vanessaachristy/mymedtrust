// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;
pragma experimental ABIEncoderV2;

contract MainContract {
    struct User {
        address addr;
        string IC;
        string name;
        string gender;
        string birthdate;
        string email;
        string homeAddress;
        string phone;
        uint userSince;
    }

    struct Doctor {
        User primaryInfo;
        string qualification;
        string major;
    }

    enum RecordStatus {
        PENDING,
        COMPLETED,
        DECLINED
    }

    struct Record {
        string encryptedID;
        string dataHash;
        address issuerDoctorAddr;
        uint timestamp;
        RecordStatus recordStatus;
    }

    struct Patient {
        User primaryInfo;
        string emergencyContact;
        string emergencyNumber;
        string bloodType;
        string height;
        string weight;
        address[] whitelistedDoctor;
        string[] recordList;
    }

    uint public totalPatients = 0;
    uint public totalDoctors = 0;
    mapping(address => Patient) public patientList;
    mapping(address => Doctor) public doctorList;
    mapping(string => Record) public recordList;
    mapping(address => bool) isPatient;
    mapping(address => bool) isDoctor;

    event PatientCreated(
        address patientAddr,
        string patientName,
        string patientIC,
        uint timestamp
    );

    event DoctorCreated(
        address doctorAddr,
        string doctorName,
        string doctorIC,
        uint timestamp
    );

    event WhitelistDoctor(
        address patientAddr,
        address doctorAddr,
        uint timestamp
    );

    event RecordCreated(
        string encryptedID,
        string dataHash,
        address issuerDoctorAddr,
        uint timestamp,
        RecordStatus recordStatus,
        address patientAddr
    );

    function createPatient(
        User memory userInfo,
        string memory _emergencyContact,
        string memory _emergencyNumber,
        string memory _bloodType,
        string memory _height,
        string memory _weight,
        address[] memory _whitelistedDoctor,
        string[] memory _recordList
    ) public {
        address patientAddress = userInfo.addr;

        require(!isPatient[userInfo.addr]);
        isPatient[patientAddress] = true;

        uint timestamp = userInfo.userSince;
        patientList[patientAddress].primaryInfo = userInfo;
        patientList[patientAddress].emergencyContact = _emergencyContact;
        patientList[patientAddress].emergencyNumber = _emergencyNumber;
        patientList[patientAddress].bloodType = _bloodType;
        patientList[patientAddress].height = _height;
        patientList[patientAddress].weight = _weight;

        // address[] memory whitelistedDoctor;
        for (uint i = 0; i < _whitelistedDoctor.length; i++) {
            require(isDoctor[_whitelistedDoctor[i]]);
        }
        patientList[patientAddress].whitelistedDoctor = _whitelistedDoctor;
        patientList[patientAddress].recordList = _recordList;

        totalPatients++;

        emit PatientCreated(
            userInfo.addr,
            userInfo.name,
            userInfo.IC,
            timestamp
        );
    }

    function setPatientDetails(
        User memory userInfo,
        string memory _emergencyContact,
        string memory _emergencyNumber,
        string memory _bloodType,
        string memory _height,
        string memory _weight,
        address[] memory _whitelistedDoctor,
        string[] memory _recordList
    ) public {
        address patientAddress = userInfo.addr;
        require(isPatient[patientAddress]);
        // Update all except address & userSince
        patientList[patientAddress].primaryInfo.IC = userInfo.IC;
        patientList[patientAddress].primaryInfo.name = userInfo.name;
        patientList[patientAddress].primaryInfo.gender = userInfo.gender;
        patientList[patientAddress].primaryInfo.birthdate = userInfo.birthdate;
        patientList[patientAddress].primaryInfo.email = userInfo.email;
        patientList[patientAddress].primaryInfo.homeAddress = userInfo
            .homeAddress;
        patientList[patientAddress].primaryInfo.phone = userInfo.phone;

        patientList[patientAddress].emergencyContact = _emergencyContact;
        patientList[patientAddress].emergencyNumber = _emergencyNumber;
        patientList[patientAddress].bloodType = _bloodType;
        patientList[patientAddress].height = _height;
        patientList[patientAddress].weight = _weight;

        // address[] memory whitelistedDoctor;
        for (uint i = 0; i < _whitelistedDoctor.length; i++) {
            require(isDoctor[_whitelistedDoctor[i]]);
        }
        patientList[patientAddress].whitelistedDoctor = _whitelistedDoctor;
        patientList[patientAddress].recordList = _recordList;
    }

    function addWhitelistedDoctor(
        address doctorAddress,
        address patientAddress
    ) public {
        require(isDoctor[doctorAddress]);
        require(isPatient[patientAddress]);
        patientList[patientAddress].whitelistedDoctor.push(doctorAddress);

        emit WhitelistDoctor(doctorAddress, patientAddress, block.timestamp);
    }

    function removeWhitelistedDoctor(
        address doctorAddress,
        address patientAddress
    ) public {
        require(isDoctor[doctorAddress]);
        require(isPatient[patientAddress]);

        for (
            uint i = 0;
            i < patientList[patientAddress].whitelistedDoctor.length;
            i++
        ) {
            if (
                keccak256(
                    abi.encodePacked(
                        patientList[patientAddress].whitelistedDoctor[i]
                    )
                ) == keccak256(abi.encodePacked(doctorAddress))
            ) {
                patientList[patientAddress].whitelistedDoctor[i] = patientList[
                    patientAddress
                ].whitelistedDoctor[
                        patientList[patientAddress].whitelistedDoctor.length - 1
                    ];
                patientList[patientAddress].whitelistedDoctor.pop();
                break;
            }
        }
    }

    function getPatientDetails(
        address patientAddress
    ) public view returns (Patient memory) {
        return patientList[patientAddress];
    }

    function createDoctor(
        User memory userInfo,
        string memory _qualification,
        string memory _major
    ) public {
        address doctorAddress = userInfo.addr;
        require(!isDoctor[doctorAddress]);

        isDoctor[doctorAddress] = true;
        uint timestamp = userInfo.userSince;

        doctorList[doctorAddress].primaryInfo = userInfo;
        doctorList[doctorAddress].qualification = _qualification;
        doctorList[doctorAddress].major = _major;

        totalDoctors++;

        emit DoctorCreated(
            userInfo.addr,
            userInfo.name,
            userInfo.IC,
            timestamp
        );
    }

    function setDoctorDetails(
        User memory userInfo,
        string memory _qualification,
        string memory _major
    ) public {
        address doctorAddress = userInfo.addr;
        require(isDoctor[doctorAddress]);

        // Update all except address & userSince
        doctorList[doctorAddress].primaryInfo.IC = userInfo.IC;
        doctorList[doctorAddress].primaryInfo.name = userInfo.name;
        doctorList[doctorAddress].primaryInfo.gender = userInfo.gender;
        doctorList[doctorAddress].primaryInfo.birthdate = userInfo.birthdate;
        doctorList[doctorAddress].primaryInfo.email = userInfo.email;
        doctorList[doctorAddress].primaryInfo.homeAddress = userInfo
            .homeAddress;
        doctorList[doctorAddress].primaryInfo.phone = userInfo.phone;
        doctorList[doctorAddress].qualification = _qualification;
        doctorList[doctorAddress].major = _major;
    }

    function getDoctorDetails(
        address doctorAddress
    ) public view returns (Doctor memory) {
        return doctorList[doctorAddress];
    }

    function createRecord(
        string memory _encryptedID,
        string memory _dataHash,
        address _issuerDoctorAddr,
        address _patientAddr
    ) public {
        require(isDoctor[_issuerDoctorAddr]);
        require(isPatient[_patientAddr]);

        uint timestamp = block.timestamp;
        RecordStatus recordStatus = RecordStatus.PENDING;

        recordList[_encryptedID].encryptedID = _encryptedID;
        recordList[_encryptedID].dataHash = _dataHash;
        recordList[_encryptedID].issuerDoctorAddr = _issuerDoctorAddr;
        recordList[_encryptedID].timestamp = timestamp;
        recordList[_encryptedID].recordStatus = recordStatus;

        patientList[_patientAddr].recordList.push(_encryptedID);

        emit RecordCreated(
            _encryptedID,
            _dataHash,
            _issuerDoctorAddr,
            timestamp,
            recordStatus,
            _patientAddr
        );
    }

    function getRecordDetails(
        string memory _encryptedID
    ) public view returns (Record memory) {
        return recordList[_encryptedID];
    }

    function editRecord(
        string memory _encryptedID,
        string memory _dataHash,
        address _issuerDoctorAddr,
        RecordStatus _recordStatus
    ) public {
        uint timestamp = block.timestamp;
        recordList[_encryptedID].encryptedID = _encryptedID;
        recordList[_encryptedID].dataHash = _dataHash;
        recordList[_encryptedID].issuerDoctorAddr = _issuerDoctorAddr;
        recordList[_encryptedID].timestamp = timestamp;
        recordList[_encryptedID].recordStatus = _recordStatus;
    }

    function removeRecord(
        string memory _encryptedID,
        address _patientAddress
    ) public {
        require(isPatient[_patientAddress]);
        delete recordList[_encryptedID];

        for (
            uint i = 0;
            i < patientList[_patientAddress].recordList.length;
            i++
        ) {
            if (
                keccak256(
                    abi.encodePacked(patientList[_patientAddress].recordList[i])
                ) == keccak256(abi.encodePacked(_encryptedID))
            ) {
                patientList[_patientAddress].recordList[i] = patientList[
                    _patientAddress
                ].recordList[
                        patientList[_patientAddress].recordList.length - 1
                    ];
                patientList[_patientAddress].recordList.pop();
                break;
            }
        }
    }
}
