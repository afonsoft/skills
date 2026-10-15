# Node environment reproduction

Default order on Node side:

1. Import target script
2. Minimal shim host object
3. Run the entry function
4. Record the first exception or first divergence
5. Return to the page to fill in the gaps with evidence