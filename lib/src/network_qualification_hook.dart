/// Called when the overlay network context label changes.
///
/// Host apps can wire this to HTTP client throttling or offline simulation.
typedef NetworkQualificationHook =
    void Function(String profile, double referenceLatencyMs);
