import 'package:flutter/material.dart';
import 'package:flutter_polylin_3/address_search.dart';

void main() {
  runApp(const VitaxiApp());
}

class VitaxiApp extends StatelessWidget {
  const VitaxiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: VitaxiHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class VitaxiHomePage extends StatelessWidget {
  const VitaxiHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(170.0),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xff5A4CE5),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20.0),
              bottomRight: Radius.circular(20.0),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Vitaxi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.card_giftcard, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'VitaxiPay Balance',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    '\$1,893.10',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddressSearchScreen()),
                  );
                },
              child: const WhereToSection()),
            const SizedBox(height: 20),
            const RideOptions(),
            const SizedBox(height: 20),
            const SavedAddresses(),
            const SizedBox(height: 20),
            const ClaimSection(),
            const SizedBox(height: 20),
            const RecentRides(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class WhereToSection extends StatelessWidget {
  const WhereToSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6.0,
            spreadRadius: 2.0,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.location_pin, color: Colors.red),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Where to?',
              style: TextStyle(fontSize: 16.0),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.purple, backgroundColor: Colors.white,
            ),
            onPressed: () {},
            child: const Text('Open Map'),
          ),
        ],
      ),
    );
  }
}

class RideOptions extends StatelessWidget {
  const RideOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RideOption(icon: Icons.directions_car, label: 'Car'),
        RideOption(icon: Icons.pedal_bike, label: 'Bike'),
        RideOption(icon: Icons.car_rental, label: 'Rent'),
        RideOption(icon: Icons.airport_shuttle, label: 'Shuttle'),
      ],
    );
  }
}

class RideOption extends StatelessWidget {
  final IconData icon;
  final String label;

  RideOption({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.grey[200],
          child: Icon(icon, color: Colors.purple),
        ),
        const SizedBox(height: 8.0),
        Text(label),
      ],
    );
  }
}

class SavedAddresses extends StatelessWidget {
  const SavedAddresses({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Saved Address', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
        ListTile(
          leading: const Icon(Icons.home, color: Colors.orange),
          title: const Text('Home'),
          subtitle: const Text('66 Prince Consort Road, Kelleth CA10 5DS'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.work, color: Colors.orange),
          title: const Text('Office'),
          subtitle: const Text('11 Prospect Hill, Drinkstone Green IP30 4DS'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {},
        ),
      ],
    );
  }
}

class ClaimSection extends StatelessWidget {
  const ClaimSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Claim Now! Discount 15% For New User!',
              style: TextStyle(color: Colors.white),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(),
            onPressed: () {},
            child: const Text('Claim'),
          ),
        ],
      ),
    );
  }
}

class RecentRides extends StatelessWidget {
  const RecentRides({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Ride', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey[200],
            child: const Icon(Icons.directions_car, color: Colors.purple),
          ),
          title: const Text('11 Prospect Hill -> 66 Prince Consort Road'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {},
        ),
      ],
    );
  }
}
