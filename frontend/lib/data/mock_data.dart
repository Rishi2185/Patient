import '../models/doctor.dart';
import '../models/hospital.dart';
import '../models/review.dart';
import '../models/specialty.dart';

/// Static, in-memory mock dataset that powers the demo (no backend).
class MockData {
  MockData._();

  // ---------------------------------------------------------------------------
  // Hospitals
  // ---------------------------------------------------------------------------
  static final List<Hospital> hospitals = [
    Hospital(
      id: 'h1',
      name: 'Aarvy Multispeciality Hospital',
      address: '12 Wellington Road, Bandra West',
      city: 'Mumbai',
      rating: 4.8,
      phone: '+91 22 4567 8900',
      imageUrl: 'https://picsum.photos/seed/aarvyhospital/900/600',
      galleryUrls: [
        'https://picsum.photos/seed/aarvylobby/600/400',
        'https://picsum.photos/seed/aarvyward/600/400',
        'https://picsum.photos/seed/aarvyicu/600/400',
        'https://picsum.photos/seed/aarvylab/600/400',
      ],
      departments: [
        'Cardiology',
        'Neurology',
        'Pediatrics',
        'Orthopedics',
        'General Medicine',
      ],
      facilities: [
        HospitalFacility('24/7 Emergency', 'emergency'),
        HospitalFacility('Pharmacy', 'pharmacy'),
        HospitalFacility('ICU', 'icu'),
        HospitalFacility('Ambulance', 'ambulance'),
        HospitalFacility('Lab & Diagnostics', 'lab'),
        HospitalFacility('Parking', 'parking'),
      ],
      about:
          'A NABH-accredited multispeciality hospital with 250+ beds, advanced '
          'diagnostics and a patient-first approach to care. Trusted by over '
          '1 lakh families across Mumbai.',
      openHours: 'Open 24 hours',
      distanceKm: 2.4,
      latitude: 19.0596,
      longitude: 72.8295,
    ),
    Hospital(
      id: 'h2',
      name: 'GreenLeaf Heart & Care Centre',
      address: '45 MG Road, Indiranagar',
      city: 'Bengaluru',
      rating: 4.7,
      phone: '+91 80 2233 4455',
      imageUrl: 'https://picsum.photos/seed/greenleaf/900/600',
      galleryUrls: [
        'https://picsum.photos/seed/greenleaf1/600/400',
        'https://picsum.photos/seed/greenleaf2/600/400',
        'https://picsum.photos/seed/greenleaf3/600/400',
      ],
      departments: ['Cardiology', 'ENT', 'Dermatology', 'General Medicine'],
      facilities: [
        HospitalFacility('Cardiac ICU', 'icu'),
        HospitalFacility('Pharmacy', 'pharmacy'),
        HospitalFacility('Lab & Diagnostics', 'lab'),
        HospitalFacility('Cafeteria', 'cafe'),
        HospitalFacility('Parking', 'parking'),
      ],
      about:
          'A specialised cardiac and wellness centre combining warm, '
          'personalised care with the latest in heart-health technology.',
      openHours: 'Mon - Sat, 8:00 AM - 9:00 PM',
      distanceKm: 5.1,
      latitude: 12.9719,
      longitude: 77.6412,
    ),
    Hospital(
      id: 'h3',
      name: 'Sunrise Women & Child Clinic',
      address: '88 Park Street',
      city: 'Kolkata',
      rating: 4.9,
      phone: '+91 33 6677 8899',
      imageUrl: 'https://picsum.photos/seed/sunrisewc/900/600',
      galleryUrls: [
        'https://picsum.photos/seed/sunrise1/600/400',
        'https://picsum.photos/seed/sunrise2/600/400',
        'https://picsum.photos/seed/sunrise3/600/400',
      ],
      departments: ['Gynecology', 'Pediatrics', 'Dermatology'],
      facilities: [
        HospitalFacility('Maternity Ward', 'icu'),
        HospitalFacility('NICU', 'icu'),
        HospitalFacility('Pharmacy', 'pharmacy'),
        HospitalFacility('Play Area', 'cafe'),
        HospitalFacility('Parking', 'parking'),
      ],
      about:
          'A gentle, family-focused clinic dedicated to women and children, '
          'offering compassionate maternity, fertility and pediatric care.',
      openHours: 'Open 24 hours',
      distanceKm: 3.8,
      latitude: 22.5535,
      longitude: 88.3520,
    ),
    Hospital(
      id: 'h4',
      name: 'Apex Bone & Joint Institute',
      address: '7 Civil Lines',
      city: 'Delhi',
      rating: 4.6,
      phone: '+91 11 4040 5050',
      imageUrl: 'https://picsum.photos/seed/apexbone/900/600',
      galleryUrls: [
        'https://picsum.photos/seed/apex1/600/400',
        'https://picsum.photos/seed/apex2/600/400',
      ],
      departments: ['Orthopedics', 'Neurology', 'General Medicine'],
      facilities: [
        HospitalFacility('Physiotherapy', 'lab'),
        HospitalFacility('Pharmacy', 'pharmacy'),
        HospitalFacility('Digital X-Ray', 'lab'),
        HospitalFacility('Parking', 'parking'),
      ],
      about:
          'A centre of excellence for orthopedics and sports medicine with '
          'modern operation theatres and dedicated rehab facilities.',
      openHours: 'Mon - Sun, 7:00 AM - 10:00 PM',
      distanceKm: 6.7,
      latitude: 28.6790,
      longitude: 77.2270,
    ),
    Hospital(
      id: 'h5',
      name: 'ClearVision Eye & Dental',
      address: '23 Anna Salai',
      city: 'Chennai',
      rating: 4.5,
      phone: '+91 44 2828 3939',
      imageUrl: 'https://picsum.photos/seed/clearvision/900/600',
      galleryUrls: [
        'https://picsum.photos/seed/clear1/600/400',
        'https://picsum.photos/seed/clear2/600/400',
      ],
      departments: ['Eye Care', 'Dentistry', 'ENT'],
      facilities: [
        HospitalFacility('Day Care Surgery', 'icu'),
        HospitalFacility('Optical Store', 'pharmacy'),
        HospitalFacility('Lab & Diagnostics', 'lab'),
        HospitalFacility('Parking', 'parking'),
      ],
      about:
          'Advanced eye and dental care under one roof, with laser suites and '
          'a friendly team focused on comfortable, modern treatment.',
      openHours: 'Mon - Sat, 9:00 AM - 8:00 PM',
      distanceKm: 4.2,
      latitude: 13.0604,
      longitude: 80.2496,
    ),
  ];

  // ---------------------------------------------------------------------------
  // Doctors
  // ---------------------------------------------------------------------------
  static final List<Doctor> doctors = [
    Doctor(
      id: 'd1',
      name: 'Dr. Ananya Sharma',
      specialty: Specialties.cardiology,
      qualifications: 'MBBS, MD, DM (Cardiology)',
      experienceYears: 14,
      rating: 4.9,
      reviewCount: 328,
      consultationFee: 800,
      about:
          'Dr. Ananya Sharma is a senior interventional cardiologist with over '
          'a decade of experience in managing complex heart conditions. She '
          'believes in preventive care and takes time to explain every option '
          'to her patients.',
      photoUrl: 'https://randomuser.me/api/portraits/women/68.jpg',
      hospitalId: 'h2',
      languages: ['English', 'Hindi', 'Kannada'],
      patientsServed: 12000,
      availableToday: true,
      availableDays: ['Mon', 'Tue', 'Wed', 'Fri', 'Sat'],
      consultStart: '09:00',
      consultEnd: '05:00',
    ),
    Doctor(
      id: 'd2',
      name: 'Dr. Rohan Mehta',
      specialty: Specialties.dermatology,
      qualifications: 'MBBS, MD (Dermatology)',
      experienceYears: 9,
      rating: 4.7,
      reviewCount: 211,
      consultationFee: 600,
      about:
          'Dr. Rohan Mehta is a cosmetic and clinical dermatologist known for '
          'his gentle approach to skin and hair concerns. He combines '
          'evidence-based treatments with modern aesthetic procedures.',
      photoUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
      hospitalId: 'h2',
      languages: ['English', 'Hindi'],
      patientsServed: 8500,
      availableToday: true,
      availableDays: ['Mon', 'Wed', 'Thu', 'Fri'],
      consultStart: '10:00',
      consultEnd: '06:00',
    ),
    Doctor(
      id: 'd3',
      name: 'Dr. Priya Nair',
      specialty: Specialties.gynecology,
      qualifications: 'MBBS, MS (Obstetrics & Gynecology)',
      experienceYears: 16,
      rating: 4.9,
      reviewCount: 402,
      consultationFee: 750,
      about:
          'Dr. Priya Nair is a compassionate gynecologist and obstetrician who '
          'has guided thousands of women through pregnancy and fertility '
          'journeys with warmth and expertise.',
      photoUrl: 'https://randomuser.me/api/portraits/women/65.jpg',
      hospitalId: 'h3',
      languages: ['English', 'Hindi', 'Malayalam', 'Bengali'],
      patientsServed: 15000,
      availableToday: false,
      availableDays: ['Tue', 'Wed', 'Thu', 'Sat'],
      consultStart: '09:30',
      consultEnd: '04:00',
    ),
    Doctor(
      id: 'd4',
      name: 'Dr. Arjun Verma',
      specialty: Specialties.pediatrics,
      qualifications: 'MBBS, MD (Pediatrics)',
      experienceYears: 11,
      rating: 4.8,
      reviewCount: 276,
      consultationFee: 550,
      about:
          'Dr. Arjun Verma is a friendly pediatrician who makes every child '
          'feel at ease. He specialises in newborn care, vaccinations and '
          'childhood nutrition.',
      photoUrl: 'https://randomuser.me/api/portraits/men/45.jpg',
      hospitalId: 'h3',
      languages: ['English', 'Hindi', 'Bengali'],
      patientsServed: 9800,
      availableToday: true,
      availableDays: ['Mon', 'Tue', 'Thu', 'Fri', 'Sat'],
      consultStart: '11:00',
      consultEnd: '07:00',
    ),
    Doctor(
      id: 'd5',
      name: 'Dr. Kavya Reddy',
      specialty: Specialties.ent,
      qualifications: 'MBBS, MS (ENT)',
      experienceYears: 8,
      rating: 4.6,
      reviewCount: 154,
      consultationFee: 500,
      about:
          'Dr. Kavya Reddy is an ENT surgeon experienced in treating sinus, '
          'hearing and throat disorders using minimally invasive techniques.',
      photoUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
      hospitalId: 'h5',
      languages: ['English', 'Telugu', 'Tamil'],
      patientsServed: 6400,
      availableToday: true,
      availableDays: ['Mon', 'Wed', 'Fri', 'Sat'],
      consultStart: '09:00',
      consultEnd: '03:00',
    ),
    Doctor(
      id: 'd6',
      name: 'Dr. Vikram Singh',
      specialty: Specialties.orthopedics,
      qualifications: 'MBBS, MS (Orthopedics)',
      experienceYears: 18,
      rating: 4.8,
      reviewCount: 389,
      consultationFee: 900,
      about:
          'Dr. Vikram Singh is a leading orthopedic and joint-replacement '
          'surgeon. He has performed over 5,000 successful surgeries and '
          'champions early physiotherapy for faster recovery.',
      photoUrl: 'https://randomuser.me/api/portraits/men/52.jpg',
      hospitalId: 'h4',
      languages: ['English', 'Hindi', 'Punjabi'],
      patientsServed: 13500,
      availableToday: false,
      availableDays: ['Tue', 'Thu', 'Fri', 'Sat'],
      consultStart: '08:00',
      consultEnd: '02:00',
    ),
    Doctor(
      id: 'd7',
      name: 'Dr. Meera Iyer',
      specialty: Specialties.neurology,
      qualifications: 'MBBS, DM (Neurology)',
      experienceYears: 13,
      rating: 4.7,
      reviewCount: 198,
      consultationFee: 950,
      about:
          'Dr. Meera Iyer is a neurologist specialising in migraine, epilepsy '
          'and movement disorders. She is known for her patient, methodical '
          'and reassuring consultations.',
      photoUrl: 'https://randomuser.me/api/portraits/women/12.jpg',
      hospitalId: 'h4',
      languages: ['English', 'Hindi', 'Tamil'],
      patientsServed: 7200,
      availableToday: true,
      availableDays: ['Mon', 'Tue', 'Wed', 'Thu'],
      consultStart: '10:00',
      consultEnd: '05:00',
    ),
    Doctor(
      id: 'd8',
      name: 'Dr. Sameer Khan',
      specialty: Specialties.generalPhysician,
      qualifications: 'MBBS, MD (General Medicine)',
      experienceYears: 10,
      rating: 4.6,
      reviewCount: 245,
      consultationFee: 400,
      about:
          'Dr. Sameer Khan is a general physician who handles everyday health '
          'concerns, chronic disease management and preventive check-ups with '
          'a friendly, no-rush approach.',
      photoUrl: 'https://randomuser.me/api/portraits/men/76.jpg',
      hospitalId: 'h1',
      languages: ['English', 'Hindi', 'Urdu'],
      patientsServed: 11000,
      availableToday: true,
      availableDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
      consultStart: '09:00',
      consultEnd: '08:00',
    ),
    Doctor(
      id: 'd9',
      name: 'Dr. Neha Gupta',
      specialty: Specialties.dentistry,
      qualifications: 'BDS, MDS (Prosthodontics)',
      experienceYears: 7,
      rating: 4.8,
      reviewCount: 167,
      consultationFee: 450,
      about:
          'Dr. Neha Gupta is a cosmetic dentist focused on pain-free dentistry, '
          'smile makeovers and dental implants in a calm, modern setting.',
      photoUrl: 'https://randomuser.me/api/portraits/women/90.jpg',
      hospitalId: 'h5',
      languages: ['English', 'Hindi'],
      patientsServed: 5300,
      availableToday: true,
      availableDays: ['Mon', 'Wed', 'Thu', 'Fri', 'Sat'],
      consultStart: '10:00',
      consultEnd: '07:00',
    ),
    Doctor(
      id: 'd10',
      name: 'Dr. Rahul Desai',
      specialty: Specialties.ophthalmology,
      qualifications: 'MBBS, MS (Ophthalmology)',
      experienceYears: 12,
      rating: 4.7,
      reviewCount: 188,
      consultationFee: 550,
      about:
          'Dr. Rahul Desai is an eye surgeon experienced in LASIK and cataract '
          'procedures, helping thousands of patients regain clear vision.',
      photoUrl: 'https://randomuser.me/api/portraits/men/15.jpg',
      hospitalId: 'h5',
      languages: ['English', 'Hindi', 'Tamil'],
      patientsServed: 8800,
      availableToday: false,
      availableDays: ['Tue', 'Wed', 'Fri', 'Sat'],
      consultStart: '09:00',
      consultEnd: '04:00',
    ),
    Doctor(
      id: 'd11',
      name: 'Dr. Ishaan Joshi',
      specialty: Specialties.cardiology,
      qualifications: 'MBBS, MD, DNB (Cardiology)',
      experienceYears: 20,
      rating: 4.9,
      reviewCount: 511,
      consultationFee: 1000,
      about:
          'Dr. Ishaan Joshi is a veteran cardiologist and one of the city\'s '
          'most trusted names in heart care, with two decades of clinical '
          'excellence behind him.',
      photoUrl: 'https://randomuser.me/api/portraits/men/3.jpg',
      hospitalId: 'h1',
      languages: ['English', 'Hindi', 'Marathi'],
      patientsServed: 21000,
      availableToday: true,
      availableDays: ['Mon', 'Tue', 'Thu', 'Fri'],
      consultStart: '08:00',
      consultEnd: '01:00',
    ),
    Doctor(
      id: 'd12',
      name: 'Dr. Sara Thomas',
      specialty: Specialties.pediatrics,
      qualifications: 'MBBS, DCH, MD (Pediatrics)',
      experienceYears: 6,
      rating: 4.7,
      reviewCount: 132,
      consultationFee: 500,
      about:
          'Dr. Sara Thomas is a young, energetic pediatrician who loves working '
          'with children and supporting first-time parents with practical '
          'advice.',
      photoUrl: 'https://randomuser.me/api/portraits/women/29.jpg',
      hospitalId: 'h1',
      languages: ['English', 'Hindi', 'Malayalam'],
      patientsServed: 4200,
      availableToday: true,
      availableDays: ['Mon', 'Wed', 'Fri', 'Sat'],
      consultStart: '11:00',
      consultEnd: '06:00',
    ),
  ];

  // ---------------------------------------------------------------------------
  // Seed reviews (per doctor)
  // ---------------------------------------------------------------------------
  static final List<Review> reviews = [
    Review(
      id: 'r1',
      doctorId: 'd1',
      patientName: 'Rebecca M.',
      rating: 5,
      comment:
          'Dr. Sharma was incredibly thorough and patient. She explained my '
          'condition clearly and never made me feel rushed.',
      date: DateTime(2026, 5, 28),
      patientAvatarUrl: 'https://randomuser.me/api/portraits/women/22.jpg',
    ),
    Review(
      id: 'r2',
      doctorId: 'd1',
      patientName: 'Karan P.',
      rating: 5,
      comment: 'Best cardiologist I have visited. Highly recommend!',
      date: DateTime(2026, 5, 10),
      patientAvatarUrl: 'https://randomuser.me/api/portraits/men/41.jpg',
    ),
    Review(
      id: 'r3',
      doctorId: 'd1',
      patientName: 'Anjali T.',
      rating: 4,
      comment: 'Great experience overall, slight wait time at the clinic.',
      date: DateTime(2026, 4, 22),
    ),
    Review(
      id: 'r4',
      doctorId: 'd2',
      patientName: 'Sneha R.',
      rating: 5,
      comment:
          'My skin has improved so much. Dr. Mehta is genuine and never '
          'over-prescribes.',
      date: DateTime(2026, 6, 1),
      patientAvatarUrl: 'https://randomuser.me/api/portraits/women/33.jpg',
    ),
    Review(
      id: 'r5',
      doctorId: 'd2',
      patientName: 'Imran S.',
      rating: 4,
      comment: 'Good consultation and clear treatment plan.',
      date: DateTime(2026, 5, 18),
    ),
    Review(
      id: 'r6',
      doctorId: 'd3',
      patientName: 'Pooja D.',
      rating: 5,
      comment:
          'Dr. Nair supported me through my entire pregnancy. Forever grateful '
          'for her care and kindness.',
      date: DateTime(2026, 6, 5),
      patientAvatarUrl: 'https://randomuser.me/api/portraits/women/55.jpg',
    ),
    Review(
      id: 'r7',
      doctorId: 'd4',
      patientName: 'Vivek N.',
      rating: 5,
      comment: 'My son actually looks forward to his check-ups now. Wonderful '
          'with kids!',
      date: DateTime(2026, 5, 30),
    ),
    Review(
      id: 'r8',
      doctorId: 'd6',
      patientName: 'Harish K.',
      rating: 5,
      comment:
          'Knee replacement went perfectly. Back on my feet faster than I '
          'expected. Thank you doctor!',
      date: DateTime(2026, 4, 14),
      patientAvatarUrl: 'https://randomuser.me/api/portraits/men/60.jpg',
    ),
    Review(
      id: 'r9',
      doctorId: 'd11',
      patientName: 'Lata V.',
      rating: 5,
      comment: 'A true expert. Calm, confident and deeply knowledgeable.',
      date: DateTime(2026, 6, 8),
    ),
    Review(
      id: 'r10',
      doctorId: 'd8',
      patientName: 'Deepak J.',
      rating: 4,
      comment: 'Reliable family doctor. Always available for a quick question.',
      date: DateTime(2026, 5, 25),
    ),
  ];

  // ---------------------------------------------------------------------------
  // Lookups
  // ---------------------------------------------------------------------------
  static Doctor doctorById(String id) =>
      doctors.firstWhere((d) => d.id == id);

  static Hospital hospitalById(String id) =>
      hospitals.firstWhere((h) => h.id == id);

  static List<Doctor> doctorsByHospital(String hospitalId) =>
      doctors.where((d) => d.hospitalId == hospitalId).toList();

  static List<Review> reviewsForDoctor(String doctorId) =>
      reviews.where((r) => r.doctorId == doctorId).toList();
}
