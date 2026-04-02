/// Represents the two customer types with different pricing tiers.
enum CustomerType {
  dealer('Dealer'),
  retailer('Retailer');

  final String label;
  const CustomerType(this.label);
}
