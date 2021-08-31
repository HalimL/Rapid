"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g;
    return g = { next: verb(0), "throw": verb(1), "return": verb(2) }, typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (_) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
exports.__esModule = true;
var functions = require("firebase-functions");
var admin = require("firebase-admin");
var cheerio = require("cheerio");
var request = require("request");
var PredictionServiceClient = require('@google-cloud/automl').v1.PredictionServiceClient;
var fs = require('fs');
admin.initializeApp();
var db = admin.firestore();
var batch = db.batch();
var projectId = 'rapid-54fd8';
var location = 'us-central1';
var modelId = 'test_kits_20210817030457';
var cloudStorageBucketName = 'rapid-54fd8.appspot.com';
var usersCollection = db.collection('users');
var certificateCollection = db.collection('certificates');
var bundeslaenderCollection = db.collection('bundeslaender');
var testsCollection = db.collection('tests');
var robertKochInstitutSeiteUrl = 'https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Fallzahlen.html';
var newBundeslandRef;
var newCertificateRef;
var coronaInfoForDeutschland = [["Baden-Württem­berg"], ["Bayern"], ["Berlin"], ["Bradenberg"], ["Bremen"], ["Hamburg"], ["Hessen"],
    ["Mecklenburg-Vorpommern"], ["Niedersachsen"], ["Nordrhein-Westfalen"], ["Rheinland-Pfalz"], ["Saarland"], ["Sachsen"], ["Sachsen-Anhalt"],
    ["Schleswig-Holstein"], ["Thürringen"], ["Deutschland"]];
var retrieveValues = function ($) {
    $('tbody tr').each(function (index, element) {
        var tds = $(element).find('td');
        var totalCases = $(tds[1]).text();
        var newCases = $(tds[2]).text();
        var last7Days = $(tds[3]).text();
        var incidenceScore = $(tds[4]).text();
        var totalDeaths = $(tds[5]).text();
        coronaInfoForDeutschland[index].push(parseInt(totalCases.split('.').join('')));
        coronaInfoForDeutschland[index].push(parseInt(newCases.split('.').join('')));
        coronaInfoForDeutschland[index].push(parseInt(last7Days.split('.').join('')));
        coronaInfoForDeutschland[index].push(parseFloat(incidenceScore.split(',').join('.')));
        coronaInfoForDeutschland[index].push(parseInt(totalDeaths.split('.').join('')));
    });
};
var writeBundeslaender = function () {
    for (var i = 0; i < coronaInfoForDeutschland.length; i++) {
        newBundeslandRef = bundeslaenderCollection.doc(coronaInfoForDeutschland[i][0]);
        batch.set(newBundeslandRef, {
            'name': coronaInfoForDeutschland[i][0],
            'totalCases': coronaInfoForDeutschland[i][1],
            'newCases': coronaInfoForDeutschland[i][2],
            'last7Days': coronaInfoForDeutschland[i][3],
            'incidenceScore': coronaInfoForDeutschland[i][4],
            'totalDeaths': coronaInfoForDeutschland[i][5]
        });
    }
    batch.commit().then(function () {
        console.log("Success!");
    });
};
var getCertificates = function () {
    var listOfDocumentIDToUpdate = [];
    var timestamp = Date.now();
    certificateCollection.get().then(function (snapshot) {
        snapshot.forEach(function (doc) {
            var certificate = doc.data();
            var certificateExpiringDateTime = Date.parse(certificate.expiringDate);
            if (certificate.expired == false && timestamp > certificateExpiringDateTime) {
                listOfDocumentIDToUpdate.push(doc.id);
                console.log(doc.id);
            }
        });
        if (listOfDocumentIDToUpdate.length > 1) {
            updateCertificates(listOfDocumentIDToUpdate);
        }
        else {
            console.log('No certificate to update!');
        }
    })["catch"](function (err) {
        console.log('Error getting documents', err);
    });
};
var updateCertificates = function (listOfDocumentIDToUpdate) { return __awaiter(void 0, void 0, void 0, function () {
    var i;
    return __generator(this, function (_a) {
        for (i = 0; i < listOfDocumentIDToUpdate.length; i++) {
            newCertificateRef = certificateCollection.doc(listOfDocumentIDToUpdate[i]);
            newCertificateRef.update("expired", true);
            console.log("Successfully updated certificates!");
        }
        return [2 /*return*/];
    });
}); };
var updateBundeslaender = function () { return __awaiter(void 0, void 0, void 0, function () {
    var i, docBeforeUpdate, newCasesBeforeUpdate, last7DaysBeforeUpdate, incidenceScoreBeforeUpdate;
    return __generator(this, function (_a) {
        switch (_a.label) {
            case 0:
                i = 0;
                _a.label = 1;
            case 1:
                if (!(i < coronaInfoForDeutschland.length)) return [3 /*break*/, 4];
                newBundeslandRef = bundeslaenderCollection.doc(coronaInfoForDeutschland[i][0]);
                return [4 /*yield*/, newBundeslandRef.get()];
            case 2:
                docBeforeUpdate = _a.sent();
                newCasesBeforeUpdate = docBeforeUpdate.get('newCases');
                last7DaysBeforeUpdate = docBeforeUpdate.get('last7Days');
                incidenceScoreBeforeUpdate = docBeforeUpdate.get('incidenceScore');
                batch.update(newBundeslandRef, {
                    'totalCases': coronaInfoForDeutschland[i][1],
                    'newCases': coronaInfoForDeutschland[i][2],
                    'last7Days': coronaInfoForDeutschland[i][3],
                    'incidenceScore': coronaInfoForDeutschland[i][4],
                    'totalDeaths': coronaInfoForDeutschland[i][5],
                    'previousIncidenceScore': incidenceScoreBeforeUpdate,
                    'previousLast7Days': last7DaysBeforeUpdate,
                    'previousNewCases': newCasesBeforeUpdate
                });
                _a.label = 3;
            case 3:
                i++;
                return [3 /*break*/, 1];
            case 4:
                batch.commit().then(function () {
                    console.log("Success!");
                });
                return [2 /*return*/];
        }
    });
}); };
function predict(filePath, testKitUID) {
    return __awaiter(this, void 0, void 0, function () {
        var client, content, request, response, annotationPayload;
        return __generator(this, function (_a) {
            switch (_a.label) {
                case 0:
                    updateTestKitPrediction(testKitUID, true);
                    client = new PredictionServiceClient();
                    content = fs.readFileSync(filePath);
                    request = {
                        name: client.modelPath(projectId, location, modelId),
                        payload: {
                            image: {
                                imageBytes: content
                            }
                        }
                    };
                    return [4 /*yield*/, client.predict(request)];
                case 1:
                    response = _a.sent();
                    annotationPayload = response.payload;
                    updateTestKitLabel(testKitUID, annotationPayload);
                    updateTestKitPrediction(testKitUID, false);
                    return [2 /*return*/];
            }
        });
    });
}
var updateTestKitPrediction = function (testKitUID, predicting) {
    testsCollection.doc(testKitUID).update("predicting", predicting);
    if (predicting) {
        console.log('Started predicting');
    }
    else {
        console.log('Finished predicting');
    }
};
var updateTestKitLabel = function (testKitUID, label) {
    testsCollection.doc(testKitUID).update("label", label);
    console.log("The label was: " + label);
};
var deleteUser = function (uid) {
    usersCollection.doc(uid)["delete"]();
};
exports.scheduledWriteToBundesland = functions.pubsub.schedule('25 14 * * *')
    .timeZone('Europe/Berlin')
    .onRun(function (context) { return __awaiter(void 0, void 0, void 0, function () {
    return __generator(this, function (_a) {
        request(robertKochInstitutSeiteUrl, function (error, response, html) {
            if (!error && response.statusCode == 200) {
                var $ = cheerio.load(html);
                retrieveValues($);
                writeBundeslaender();
                console.log("Successfully added bundeslaender at 14:25 Berlin Time!!");
            }
        });
        return [2 /*return*/];
    });
}); });
exports.scheduledUpdateToBundesland = functions.pubsub.schedule('00 09 * * 1-5')
    .timeZone('Europe/Berlin')
    .onRun(function (context) { return __awaiter(void 0, void 0, void 0, function () {
    return __generator(this, function (_a) {
        request(robertKochInstitutSeiteUrl, function (error, response, html) {
            if (!error && response.statusCode == 200) {
                var $ = cheerio.load(html);
                retrieveValues($);
                updateBundeslaender();
                console.log("Successfully updated bundeslaender at 09:00 Berlin Time!!");
            }
        });
        return [2 /*return*/];
    });
}); });
exports.scheduledUpdateToCertificates = functions.pubsub.schedule('0 * * * *')
    .timeZone('Europe/Berlin')
    .onRun(function (context) {
    getCertificates();
});
exports.deleteFireStoreDoc =
    functions.auth.user().onDelete(function (user) {
        deleteUser(user.uid);
    });
exports.verifyTestKit = functions.storage.bucket(cloudStorageBucketName).object().onFinalize(function (object) { return __awaiter(void 0, void 0, void 0, function () {
    var imageName, customMetadata, filePath, testKitUID;
    return __generator(this, function (_a) {
        imageName = object.name;
        customMetadata = object.metadata;
        if (imageName === null || imageName === void 0 ? void 0 : imageName.startsWith('tests')) {
            filePath = "https://storage.cloud.google.com/rapid-54fd8.appspot.com/${imageName}";
            testKitUID = customMetadata['testKitUID'];
            predict(filePath, testKitUID);
        }
        return [2 /*return*/];
    });
}); });
