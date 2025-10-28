import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';
import '../models/review.dart';
import '../services/booking_service.dart';
import '../services/review_service.dart';
import '../constants/app_colors.dart';

class BookingDetailScreen extends StatefulWidget {
  final String bookingId;

  const BookingDetailScreen({Key? key, required this.bookingId})
    : super(key: key);

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  final BookingService _bookingService = BookingService();
  final ReviewService _reviewService = ReviewService();

  Booking? _booking;
  List<Review> _reviews = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final booking = await _bookingService.getBookingDetail(widget.bookingId);
      final reviews = await _reviewService.getReviewsByBooking(
        widget.bookingId,
      );

      setState(() {
        _booking = booking;
        _reviews = reviews;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đặt phòng'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _booking == null
          ? const Center(child: Text('Không tìm thấy thông tin'))
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusCard(),
                    const SizedBox(height: 16),
                    _buildBookingInfo(),
                    const SizedBox(height: 16),
                    _buildRoomInfo(),
                    if (_booking!.user != null) ...[
                      const SizedBox(height: 16),
                      _buildUserInfo(),
                    ],
                    if (_reviews.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildReviewsSection(),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatusCard() {
    final booking = _booking!;
    Color statusColor;
    IconData statusIcon;

    switch (booking.status.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case 'confirmed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'completed':
        statusColor = Colors.blue;
        statusIcon = Icons.done_all;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor, statusColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(statusIcon, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trạng thái',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  booking.status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingInfo() {
    final booking = _booking!;
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return _buildCard(
      title: 'Thông tin đặt phòng',
      icon: Icons.event_note,
      child: Column(
        children: [
          _buildInfoRow(
            Icons.confirmation_number,
            'Mã đặt phòng',
            booking.id.substring(0, 13) + '...',
          ),
          const Divider(height: 24),
          _buildInfoRow(
            Icons.event,
            'Check-in',
            DateFormat('dd/MM/yyyy').format(booking.startDate),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.event_available,
            'Check-out',
            DateFormat('dd/MM/yyyy').format(booking.endDate),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.nights_stay,
            'Số đêm',
            '${booking.numberOfNights} đêm',
          ),
          const Divider(height: 24),
          _buildInfoRow(
            Icons.payments,
            'Tổng tiền',
            currencyFormat.format(booking.totalPrice),
            valueStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          if (booking.note.isNotEmpty) ...[
            const Divider(height: 24),
            _buildInfoRow(Icons.note, 'Ghi chú', booking.note),
          ],
        ],
      ),
    );
  }

  Widget _buildRoomInfo() {
    final room = _booking!.room;
    if (room == null) return const SizedBox.shrink();

    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return _buildCard(
      title: 'Thông tin phòng',
      icon: Icons.hotel,
      child: Column(
        children: [
          _buildInfoRow(Icons.category, 'Loại phòng', room.categoryName),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.attach_money,
            'Giá phòng',
            currencyFormat.format(room.price),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.local_offer,
            'Giảm giá',
            '${room.discount}%',
            valueStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    final user = _booking!.user!;

    return _buildCard(
      title: 'Thông tin người đặt',
      icon: Icons.person,
      child: Column(
        children: [
          _buildInfoRow(Icons.person_outline, 'Họ tên', user.fullName),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.email_outlined, 'Email', user.email),
          if (user.phoneNumber != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.phone_outlined,
              'Số điện thoại',
              user.phoneNumber!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return _buildCard(
      title: 'Đánh giá',
      icon: Icons.star,
      child: Column(
        children: _reviews.map((review) => _buildReviewCard(review)).toList(),
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ...List.generate(5, (index) {
                return Icon(
                  index < review.rating
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: index < review.rating ? Colors.amber : Colors.grey,
                  size: 20,
                );
              }),
              const SizedBox(width: 8),
              Text(
                DateFormat('dd/MM/yyyy').format(review.createdAt),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.comment,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    TextStyle? valueStyle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style:
                    valueStyle ??
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
