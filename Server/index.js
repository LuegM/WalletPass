const path = require('path');
const fs = require('fs');
const crypto = require('crypto');
const fastify = require('fastify')(
	{
	  logger: true,
	  bodyLimit: 15 * 1048576,
	}
);
const { PKPass } = require('passkit-generator');

// Certificates
const certDirectory = path.resolve(process.cwd(), 'cert');
const wwdr = fs.readFileSync(path.join(certDirectory, 'wwdr.pem'));
const signerCert = fs.readFileSync(path.join(certDirectory, 'signerCert.pem'));
const signerKey = fs.readFileSync(path.join(certDirectory, 'signerKey.key'));

fastify.post('/', async (request, reply) => {
  const {
    name,
    cardNr,
    dateFrom,
    dateTo,
    dateBirth,
    aztecCode,
    type,
    image
  } = request.body;

  const passID = crypto.createHash('md5').update(`${name}_${Date.now()}`).digest('hex')


// Generate the pass
const pass = await PKPass.from(
  {
	// Path to your pass model directory
    model: path.resolve(process.cwd(), 'transit.pass'),  
    certificates: {
      wwdr,
      signerCert,
      signerKey,
    },
  },
  {
    serialNumber: passID,
  },
);

// MARK: add Infos to the pass
// Barcode Type
const barcode = {
  format: "PKBarcodeFormatAztec",
  message: aztecCode,
  messageEncoding: "iso-8859-1"
};

// Barcode Data
pass.setBarcodes(barcode);

// Expiration Format
const [day, month, year] = dateTo.split('.');
const date = new Date(`${year}-${month}-${day}T23:59:00+01:00`);

// Expiration Date
pass.setExpirationDate(date);

// headerFields
pass.headerFields.push(
    {
      key: 'type',
      value: type
    }
);

// primaryFields
pass.primaryFields.push(
	{
	  key: 'name',
	  value: name
	}
);

// secondaryFields
pass.secondaryFields.push(
	{
	  key: 'cardNr',
	  label: "Kartennummer",
	  value: cardNr
	},
	{
	  key: 'dateTo',
	  label: "Ablaufdatum",
	  value: dateTo
	},
);

// auxiliaryFields
pass.auxiliaryFields.push(
    {
      key: 'dateBirth',
      label: "Geburtsdatum",
      value: dateBirth
    },
    {
      key: 'dateFrom',
      label: "Beginn",
      value: dateFrom
    }
);

// Add a Image to the pass
// Decode the image from Base64 and save or use it directly
const imageBuffer = Buffer.from(image, "base64");
    
// Now you can use the image in your PKPass
pass.addBuffer("thumbnail.png", imageBuffer);
pass.addBuffer("thumbnail@2x.png", imageBuffer);

reply.header('Content-Type', 'application/vnd-apple.pkpass');
reply.send(pass.getAsBuffer());
});

// Start the server
fastify.listen({ port: process.env.PORT ?? 3000, host: '0.0.0.0' }, function (err) {
  if (err) {
    fastify.log.error(err);
    process.exit(1);
  }
  fastify.log.info(`Server listening on ${fastify.server.address().port}`);
});