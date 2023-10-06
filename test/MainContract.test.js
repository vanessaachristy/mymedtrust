const { assert } = require("chai");

const MainContract = artifacts.require("./MainContract.sol");

contract("Main", (accounts) => {

    before(async () => {
        this.mainContract = await MainContract.deployed();
    })

    it("deployed successfully", async () => {
        const address = await this.mainContract.address;
        assert.notEqual(address, "");
        assert.notEqual(address, null);
        assert.notEqual(address, undefined);
    })
    it("create patient", async () => {
        let unixTS = Math.floor(new Date().getTime() / 1000);
        const patientAddress = accounts[0];

        await this.mainContract.createPatient.sendTransaction({
            addr: patientAddress,
            IC: "testPatientIC",
            name: "testPatientName",
            gender: "testPatientGender",
            birthdate: "testPatientBirhtDate",
            email: "testPatient@gmail.com",
            homeAddress: "testPatientHome",
            phone: "12345678",
            userSince: unixTS,
        }, "testEmergencyContact", "testEmergencyNo", "testBloodType", "testHeight", "testWeight", [], [], { from: patientAddress })
        const patientCount = await this.mainContract.totalPatients();
        const patient = await this.mainContract.getPatientDetails.call(patientAddress);
        assert.equal(patient.primaryInfo.name, "testPatientName");
        assert.equal(patient.primaryInfo.IC, "testPatientIC");
        assert.equal(patient.primaryInfo.userSince, unixTS);
        assert.equal(patient.emergencyContact, "testEmergencyContact");
        assert.equal(patientCount.toNumber(), 1);
    })

    it("getPatientByAddress: valid case", async () => {
        const patient = await this.mainContract.getPatientDetails.call(accounts[0]);
        assert.equal(patient.primaryInfo.addr, accounts[0]);
        assert.equal(patient.primaryInfo.name, "testPatientName");
    })

    it("getPatientByAddress: invalid case", async () => {
        const patient = await this.mainContract.getPatientDetails.call(accounts[5]);
        assert.equal(patient.primaryInfo.addr, "0x0000000000000000000000000000000000000000");
        assert.equal(patient.primaryInfo.name, "");
    })

    it("update existing patient", async () => {
        const patientAddress = accounts[0];
        const before = await this.mainContract.getPatientDetails.call(patientAddress);
        try {
            await this.mainContract.setPatientDetails.sendTransaction({
                addr: accounts[0],
                IC: "testPatientICNew",
                name: "testPatientNameNew",
                gender: "testPatientGenderNew",
                birthdate: "testPatientBirhtDate",
                email: "testPatient@gmail.com",
                homeAddress: "testPatientHome",
                phone: "12345678",
                userSince: Math.floor(new Date('2012.08.10').getTime() / 1000),
            }, "testEmergencyContactNew", "testEmergencyNo", "testBloodType", "testHeight", "testWeight", [], [], { from: patientAddress })
            const after = await this.mainContract.getPatientDetails.call(patientAddress);
            const patientCount = await this.mainContract.totalPatients();
            assert.equal(after.primaryInfo.addr, patientAddress);
            assert.equal(after.primaryInfo.name, "testPatientNameNew");
            assert.equal(after.primaryInfo.IC, "testPatientICNew");
            assert.equal(after.primaryInfo.userSince, before.primaryInfo.userSince);
            assert.equal(after.emergencyContact, "testEmergencyContactNew");
            assert.equal(patientCount.toNumber(), 1);
        } catch (e) {
            console.log("Error: ", e);
        }
    })

    it("should not update previously non-existing patient", async () => {
        const patientAddress = accounts[0];
        const before = await this.mainContract.getPatientDetails.call(patientAddress);
        try {
            await this.mainContract.setPatientDetails.sendTransaction({
                addr: accounts[5],
                IC: "testPatientICNew",
                name: "testPatientNameNew",
                gender: "testPatientGenderNew",
                birthdate: "testPatientBirhtDate",
                email: "testPatient@gmail.com",
                homeAddress: "testPatientHome",
                phone: "12345678",
                userSince: Math.floor(new Date('2012.08.10').getTime() / 1000),
            }, "testEmergencyContactNew", "testEmergencyNo", "testBloodType", "testHeight", "testWeight", [], [], { from: patientAddress })
            assert.fail("The transaction should have thrown an error");
        } catch (e) {
            assert.equal(e.reason, "Address is not a patient!");
        }
    })

    it("should not update existing patient with invalid whitelisted doctor", async () => {
        const patientAddress = accounts[0];
        const before = await this.mainContract.getPatientDetails.call(patientAddress);
        try {
            await this.mainContract.setPatientDetails.sendTransaction({
                addr: accounts[0],
                IC: "testPatientICNew",
                name: "testPatientNameNew",
                gender: "testPatientGenderNew",
                birthdate: "testPatientBirhtDate",
                email: "testPatient@gmail.com",
                homeAddress: "testPatientHome",
                phone: "12345678",
                userSince: Math.floor(new Date('2012.08.10').getTime() / 1000),
            }, "testEmergencyContactNew", "testEmergencyNo", "testBloodType", "testHeight", "testWeight", [accounts[1]], [], { from: patientAddress })
            assert.fail("The transaction should have thrown an error");
        } catch (e) {
            assert.equal(e.reason, 'Whitelisted doctor contains non-doctor');
        }
    })

    it("create doctor", async () => {
        let unixTS = Math.floor(new Date().getTime() / 1000);
        const doctorAddress = accounts[1];

        await this.mainContract.createDoctor.sendTransaction({
            addr: accounts[1],
            IC: "testDoctorIC",
            name: "testDoctorName",
            gender: "testDoctorGender",
            birthdate: "testDoctorBirhtDate",
            email: "testPatient@gmail.com",
            homeAddress: "testDoctorHome",
            phone: "12345678",
            userSince: unixTS
        }, "testQualification", "testMajor", { from: doctorAddress })
        const doctorCount = await this.mainContract.totalDoctors();
        const doctor = await this.mainContract.getDoctorDetails.call(doctorAddress);
        assert.equal(doctor.primaryInfo.name, "testDoctorName");
        assert.equal(doctor.primaryInfo.IC, "testDoctorIC");
        assert.equal(doctor.primaryInfo.userSince, unixTS);
        assert.equal(doctorCount.toNumber(), 1);
    })


    it("update existing doctor", async () => {
        const doctorAddress = accounts[1];
        const before = await this.mainContract.getDoctorDetails.call(doctorAddress);
        await this.mainContract.setDoctorDetails.sendTransaction({
            addr: accounts[1],
            IC: "testDoctorICNew",
            name: "testDoctorNameNew",
            gender: "testDoctorGender",
            birthdate: "testDoctorBirhtDate",
            email: "testPatient@gmail.com",
            homeAddress: "testDoctorHome",
            phone: "12345678",
            userSince: Math.floor(new Date('2012.08.10').getTime() / 1000),
        }, "testQualificationNew", "testMajor", { from: doctorAddress })
        const after = await this.mainContract.getDoctorDetails.call(doctorAddress);
        const doctorCount = await this.mainContract.totalDoctors();
        assert.equal(after.primaryInfo.addr, doctorAddress);
        assert.equal(after.primaryInfo.name, "testDoctorNameNew");
        assert.equal(after.primaryInfo.IC, "testDoctorICNew");
        assert.equal(after.primaryInfo.userSince, before.primaryInfo.userSince);
        assert.equal(after.qualification, "testQualificationNew");
        assert.equal(doctorCount.toNumber(), 1);
    })

    it("should not update existing doctor", async () => {
        const doctorAddress = accounts[1];
        const before = await this.mainContract.getDoctorDetails.call(doctorAddress);
        try {
            await this.mainContract.setDoctorDetails.sendTransaction({
                addr: accounts[2],
                IC: "testDoctorICNew",
                name: "testDoctorNameNew",
                gender: "testDoctorGender",
                birthdate: "testDoctorBirhtDate",
                email: "testPatient@gmail.com",
                homeAddress: "testDoctorHome",
                phone: "12345678",
                userSince: Math.floor(new Date('2012.08.10').getTime() / 1000),
            }, "testQualificationNew", "testMajor", { from: doctorAddress });
            assert.fail("The transaction should have thrown an error");
        } catch (e) {
            assert.equal(e.reason, "Address is not a doctor!")
        }
    })


    it('whitelist doctor to patient', async () => {
        const patientAddress = accounts[0];
        const doctorAddress = accounts[1];
        await this.mainContract.addWhitelistedDoctor.sendTransaction(doctorAddress, patientAddress, { from: patientAddress });
        const patient = await this.mainContract.getPatientDetails.call(patientAddress);
        assert.equal(patient.whitelistedDoctor.includes(doctorAddress), true);
    });


    it("should update existing patient with valid whitelisted doctor", async () => {
        const patientAddress = accounts[0];

        await this.mainContract.setPatientDetails.sendTransaction({
            addr: accounts[0],
            IC: "testPatientICNew",
            name: "testPatientNameNew",
            gender: "testPatientGenderNew",
            birthdate: "testPatientBirhtDate",
            email: "testPatient@gmail.com",
            homeAddress: "testPatientHome",
            phone: "12345678",
            userSince: Math.floor(new Date('2012.08.10').getTime() / 1000),
        }, "testEmergencyContactNew", "testEmergencyNo", "testBloodType", "testHeight", "testWeight", [accounts[1]], [], { from: patientAddress })
        const patient = await this.mainContract.getPatientDetails.call(patientAddress);
        assert.equal(patient.whitelistedDoctor.includes(accounts[1]), true);

    })

    it("create new record", async () => {
        const patientAddress = accounts[0];
        const result = await this.mainContract.createRecord.sendTransaction("abcdef123", "abcdef1234567", accounts[1], patientAddress, { from: accounts[0] });
        const record = result.logs[0].args;
        assert.equal(record.encryptedID, "abcdef123");
        assert.equal(record.dataHash, "abcdef1234567");
        assert.equal(record.recordStatus.toNumber(), 0);
        assert.equal(record.patientAddr, accounts[0]);
        const patient = await this.mainContract.getPatientDetails.call(patientAddress);
        assert.equal(patient.recordList.includes("abcdef123"), true);
        const _record = await this.mainContract.getRecordDetails.call("abcdef123");
    })

    it("edit record", async () => {
        await this.mainContract.editRecord.sendTransaction("abcdef123", "efgh1234567", accounts[1], MainContract.RecordStatus.COMPLETED, { from: accounts[0] });
        const record = await this.mainContract.getRecordDetails.call("abcdef123");
        assert.equal(record.dataHash, "efgh1234567")
        assert.equal(record.recordStatus, MainContract.RecordStatus.COMPLETED)
    })

    it("delete record", async () => {
        const recordID = "abcdef123"
        const before = await this.mainContract.getPatientDetails.call(accounts[0]);
        assert.equal(before.recordList.includes(recordID), true);
        await this.mainContract.removeRecord.sendTransaction(recordID, accounts[0], { from: accounts[0] });
        const after = await this.mainContract.getPatientDetails.call(accounts[0]);
        assert.equal(after.recordList.includes(recordID), false);
        const recordList = await this.mainContract.recordList(recordID);
        assert.equal(recordList.encryptedID, "");
    })
})