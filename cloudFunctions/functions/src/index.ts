import * as functions from 'firebase-functions';
import { DocumentSnapshot } from 'firebase-functions/lib/providers/firestore';
import admin = require("firebase-admin");

const cheerio = require("cheerio");
const request = require("request");
const { Storage } = require('@google-cloud/storage');
const os = require('os');
const path = require('path');
const { PredictionServiceClient } = require('@google-cloud/automl').v1;
const fs = require('fs');

admin.initializeApp();

const db = admin.firestore();
const batch = db.batch();

const projectId = 'rapid-54fd8';
const location = 'us-central1';
const modelId = 'ICN6099235090854838272';
const cloudStorageBucketName = 'rapid-54fd8.appspot.com';

const usersCollection = db.collection('users');
const certificateCollection = db.collection('certificates');
const bundeslaenderCollection = db.collection('bundeslaender')
const testsCollection = db.collection('tests');
const robertKochInstitutSeiteUrl = 'https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Fallzahlen.html';

let newBundeslandRef: any;
let newCertificateRef: any;
let coronaInfoForDeutschland: any[][] = [["Baden-Württem­berg"], ["Bayern"], ["Berlin"], ["Bradenberg"], ["Bremen"], ["Hamburg"], ["Hessen"],
["Mecklenburg-Vorpommern"], ["Niedersachsen"], ["Nordrhein-Westfalen"], ["Rheinland-Pfalz"], ["Saarland"], ["Sachsen"], ["Sachsen-Anhalt"],
["Schleswig-Holstein"], ["Thürringen"], ["Deutschland"]];


const delay = (ms: number) => new Promise(res => setTimeout(res, ms));

const retrieveValues = ($: any) => {

    $('tbody tr').each((index: number, element: any) => {

        const tds = $(element).find('td');

        const totalCases = $(tds[1]).text();
        const newCases = $(tds[2]).text();
        const last7Days = $(tds[3]).text();
        const incidenceScore = $(tds[4]).text();
        const totalDeaths = $(tds[5]).text();

        coronaInfoForDeutschland[index].push(parseInt(totalCases.split('.').join('')));
        coronaInfoForDeutschland[index].push(parseInt(newCases.split('.').join('')));
        coronaInfoForDeutschland[index].push(parseInt(last7Days.split('.').join('')));
        coronaInfoForDeutschland[index].push(parseFloat(incidenceScore.split(',').join('.')));
        coronaInfoForDeutschland[index].push(parseInt(totalDeaths.split('.').join('')));
    });
}

let writeBundeslaender = () => {
    for (let i = 0; i < coronaInfoForDeutschland.length; i++) {
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
    batch.commit().then(() => {
        console.log("Success!");
    });
}


let updateBundeslaender = async () => {
    for (let i = 0; i < coronaInfoForDeutschland.length; i++) {
        newBundeslandRef = bundeslaenderCollection.doc(coronaInfoForDeutschland[i][0]);
        let docBeforeUpdate: DocumentSnapshot = await newBundeslandRef.get();
        let newCasesBeforeUpdate: number = docBeforeUpdate.get('newCases');
        let last7DaysBeforeUpdate: number = docBeforeUpdate.get('last7Days');
        let incidenceScoreBeforeUpdate: number = docBeforeUpdate.get('incidenceScore');

        batch.update(newBundeslandRef, {
            'totalCases': coronaInfoForDeutschland[i][1],
            'newCases': coronaInfoForDeutschland[i][2],
            'last7Days': coronaInfoForDeutschland[i][3],
            'incidenceScore': coronaInfoForDeutschland[i][4],
            'totalDeaths': coronaInfoForDeutschland[i][5],
            'previousIncidenceScore': incidenceScoreBeforeUpdate,
            'previousLast7Days': last7DaysBeforeUpdate,
            'previousNewCases': newCasesBeforeUpdate,
        });
    }
    batch.commit().then(() => {
        console.log("Success!");
    });
}


let getCertificates = () => {
    const timestamp: number = Date.now();
    var certificateID: string;
    certificateCollection.get().then(
        snapshot => {
            snapshot.forEach(
                doc => {
                    let certificate: FirebaseFirestore.DocumentData = doc.data();
                    let certificateExpiringDateTime: number = Date.parse(certificate.expiringDate);
                    if (certificate.expired == false && timestamp > certificateExpiringDateTime) {
                        certificateID = doc.id;
                        console.log(certificateID);
                        updateCertificate(certificateID);
                    }
                });
        }).catch(err => {
            console.log('Error getting documents', err);
        })
}


let updateCertificate = async (certificateID: string) => {

    newCertificateRef = certificateCollection.doc(certificateID);
    newCertificateRef.update("expired", true);
    console.log("Successfully updated certificate " + certificateID);
}


let updateTestKitPrediction = (testKitUID: string, predicting: Boolean) => {
    testsCollection.doc(testKitUID).update("predicting", predicting);
    if (predicting) {
        console.log('Started predicting');
    } else {
        console.log('Finished predicting');
    }
}

let updateTestKitLabel = (testKitUID: string, label: String) => {
    testsCollection.doc(testKitUID).update("label", label);
    console.log("The label was: " + label);
}


let deleteUser = (uid: string) => {
    usersCollection.doc(uid).delete();
}


exports.scheduledWriteToBundesland = functions.pubsub.schedule('25 14 * * *')
    .timeZone('Europe/Berlin')
    .onRun(async (context) => {
        request(robertKochInstitutSeiteUrl, (error: any, response: any, html: any) => {
            if (!error && response.statusCode == 200) {
                const $ = cheerio.load(html);
                retrieveValues($);
                writeBundeslaender();
                console.log("Successfully added bundeslaender at 14:25 Berlin Time!!");
            }
        });
    });


exports.scheduledUpdateToBundesland = functions.pubsub.schedule('0 09 * * *')
    .timeZone('Europe/Berlin')
    .onRun(async (context) => {
        request(robertKochInstitutSeiteUrl, (error: any, response: any, html: any) => {
            if (!error && response.statusCode == 200) {
                const $ = cheerio.load(html);
                retrieveValues($);
                updateBundeslaender();
                console.log("Successfully updated bundeslaender at 09:00 Berlin Time!!");
            }
        });
    });

exports.scheduledUpdateToCertificates = functions.pubsub.schedule('0 * * * *')
    .timeZone('Europe/Berlin')
    .onRun(async (context) => {
        getCertificates();
    });


exports.deleteFireStoreDoc =
    functions.auth.user().onDelete((user) => {
        deleteUser(user.uid);
    });



exports.predictTestKit = functions.storage.bucket(cloudStorageBucketName).object().onFinalize(async (object) => {
    const filePath = object.name;
    const customMetadata = object.metadata!;

    if (filePath?.startsWith('tests')) {

        const testKitUID = customMetadata['testKitUID'];

        const gcsClient = new Storage();

        const destBucket = gcsClient.bucket(cloudStorageBucketName);
        const tmpFilePath = path.join(os.tmpdir(), path.basename(filePath));

        return destBucket.file(filePath).download({
            destination: tmpFilePath
        }).then(async () => {

            updateTestKitPrediction(testKitUID, true);

            const client = new PredictionServiceClient();

            var imageFile = fs.readFileSync(tmpFilePath);
            var content = Buffer.from(imageFile).toString('base64');

            const request = {
                name: client.modelPath(projectId, location, modelId),
                payload: {
                    image: {
                        imageBytes: content,
                    },
                },
            };

            const [response] = await client.predict(request);

            var label: string;

            for (const annotationPayload of response.payload) {
                label = annotationPayload.displayName;
                updateTestKitLabel(testKitUID, label);
            }

            await delay(2000);
            updateTestKitPrediction(testKitUID, false);

            try {
                fs.unlinkSync(tmpFilePath)
                console.log('Successfully removed: ' + tmpFilePath);
            } catch (err) {
                console.error(err)
            }

        });
    }
});