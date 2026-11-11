// Product rules for the Handmark demo. Every number here is DEMO CONTENT,
// chosen to make the flow readable, not a real policy or fee schedule.

/// How long a maker has to confirm that a requested piece is still available
/// and ready to ship. No money moves before they do: a deliberate product
/// decision (one-of-one pieces sell at fairs and from the workshop too).
const kConfirmWindow = Duration(hours: 48);

/// After confirmation, how long the buyer has to finalise payment before the
/// piece is released back to the collection.
const kPaymentWindow = Duration(hours: 72);

/// Days a maker has to pack and ship once payment is finalised.
const kShipWithinDays = 7;

/// Return window after delivery.
const kReturnDays = 14;

/// DEMO CONTENT: shipping estimates for delivery within the US (the demo
/// buyer ships to Boston), in USD. Shown on the piece page before requesting
/// and again in the request summary with the total.
/// Small piece from a US maker: insured, tracked parcel.
const kShippingSmallUs = 15;

/// Small piece from a maker outside the US: insured, tracked international parcel.
const kShippingSmallIntl = 45;

/// Large piece (furniture, large canvases): crated, white-glove delivery.
const kShippingLarge = 380;

/// Where the "About this demo" link under the phone points.
const kRepoUrl = 'https://github.com/JackSantospago/Handmark#readme';
