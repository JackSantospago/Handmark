# Handmark

A clickable UI demo of **Handmark**, a curated online marketplace for verified handmade objects:
furniture, art, jewellery and glass. Every listing carries a provenance record: who made the
piece, the materials, the method, where it was made, how many hours of human work went in, and
an honest line on any machine involvement.

> Class prototype. Every maker, piece, price and specification is fictional demo content.
> Images are drawn placeholders, not photographs.

**Live preview:** https://jacksantospago.github.io/Handmark/

## Screens

1. **Collection**: curated grid of 8 verified pieces.
2. **Piece**: hero image, price, provenance record, "Request this piece".
3. **Maker**: portrait, workshop, story, other listings.
4. **Request**: send a request → the maker confirms availability **within 48 hours** → finalise payment.
   The 48-hour step is deliberate: nothing is charged before the maker confirms the one-of-one piece is ready.
5. **Invite**: early-access email capture.
6. **How we certify**: opened by tapping the "Handmark Verified" mark anywhere. Our four checks
   (maker, making, materials, piece), what the mark does and does not promise, how hours are checked,
   and the external certifications we verify at the source (FSC, PEFC, UK hallmark, Fairmined, LWG,
   food-contact testing). Each piece's provenance record lists its results, including honest
   "not certified" and "no scheme applies" cases.

## Run it

```sh
cd handmark_app
flutter run -d chrome -t lib/main_preview.dart
```

URL options (all in `lib/preview/preview_options.dart`):
`?tab=collection|makers|requests|invite`, `?piece=moon-jar`, `?page=certification`, `?requests=none`, `?theme=dark`,
`?device=android`, `?frame=off`.

## Layout

- `handmark_app/lib/preview/`: phone frame, fake data, preview options (the demo harness)
- `handmark_app/lib/core/`: catalog and request models, settings, product rules (`config.dart`)
- `handmark_app/lib/frontend/`: one folder per screen, `shared/` for theme and widgets
- `.github/workflows/pages.yml`: builds the preview and deploys it to GitHub Pages on every push to `main`

The preview harness and Pages workflow come from the Espresso-Hackers project.
