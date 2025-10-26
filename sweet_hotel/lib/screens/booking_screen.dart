import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/room.dart';
import '../models/booking.dart';
import '../services/room_service.dart';
import '../services/booking_service.dart';
import '../services/auth_service.dart';
import '../constants/app_colors.dart';
import '../widgets/custom_bottom_nav.dart';

class BookingScreen extends StatefulWidget {
  final String? preSelectedRoomId;

  const BookingScreen({Key? key, this.preSelectedRoomId}) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final RoomService _roomService = RoomService();
  final BookingService _bookingService = BookingService();
  final AuthService _authService = AuthService();

  List<Room> _availableRooms = [];
  bool _isLoading = false;
  bool _isBooking = false;

  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedRoomId;
  Room? _selectedRoom;

  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Nếu có room được pre-select, set nó
    if (widget.preSelectedRoomId != null) {
      _selectedRoomId = widget.preSelectedRoomId;
      _loadPreSelectedRoom();
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadPreSelectedRoom() async {
    try {
      final room = await _roomService.getRoomById(widget.preSelectedRoomId!);
      setState(() {
        _selectedRoom = room;
      });
    } catch (e) {
      // Không cần xử lý lỗi ở đây
    }
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        // Reset end date nếu nó trước start date
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = null;
        }
        // Reset available rooms khi thay đổi ngày
        _availableRooms = [];
      });
    }
  }

  Future<void> _selectEndDate() async {
    if (_startDate == null) {
      _showError('Vui lòng chọn ngày đến trước');
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate!.add(const Duration(days: 1)),
      firstDate: _startDate!.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
      // Tự động load phòng khi đã chọn cả 2 ngày
      _loadAvailableRooms();
    }
  }

  Future<void> _loadAvailableRooms() async {
    if (_startDate == null || _endDate == null) {
      _showError('Vui lòng chọn ngày đến và ngày đi');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Nếu có pre-selected room, chỉ kiểm tra phòng đó
      if (widget.preSelectedRoomId != null) {
        final rooms = await _roomService.getAvailableRoomsByDateRange(
          startDate: _startDate!,
          endDate: _endDate!,
        );

        final preSelectedRoom = rooms.firstWhere(
          (r) => r.id == widget.preSelectedRoomId,
          orElse: () => Room(
            id: '',
            status: '',
            amenities: '',
            price: 0,
            discount: 0,
            categoryId: '',
            categoryName: '',
            images: [],
          ),
        );

        setState(() {
          _isLoading = false;
          if (preSelectedRoom.id.isNotEmpty) {
            // Phòng vẫn available
            _selectedRoomId = preSelectedRoom.id;
            _selectedRoom = preSelectedRoom;
            _availableRooms = []; // Không cần hiển thị danh sách phòng khác

            // Hiển thị thông báo thành công
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    '✓ Phòng còn trống! Vui lòng xác nhận đặt phòng.',
                  ),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          } else {
            // Phòng không còn available
            _selectedRoomId = null;
            _selectedRoom = null;
            _showError(
              'Rất tiếc, phòng bạn chọn không còn trống trong thời gian này.',
            );
          }
        });
      } else {
        // Không có pre-selected room, load tất cả phòng available
        final rooms = await _roomService.getAvailableRoomsByDateRange(
          startDate: _startDate!,
          endDate: _endDate!,
        );

        setState(() {
          _availableRooms = rooms;
          _isLoading = false;
        });

        if (rooms.isEmpty) {
          _showError('Không có phòng trống trong khoảng thời gian này');
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Lỗi khi tải phòng: ${e.toString()}');
    }
  }

  Future<void> _createBooking() async {
    // Validate
    if (_startDate == null || _endDate == null) {
      _showError('Vui lòng chọn ngày đến và ngày đi');
      return;
    }

    if (_selectedRoomId == null) {
      _showError('Vui lòng chọn phòng');
      return;
    }

    // Get user ID
    final userId = await _authService.getUserId();
    if (userId == null) {
      _showError('Không tìm thấy thông tin người dùng. Vui lòng đăng nhập lại');
      return;
    }

    setState(() {
      _isBooking = true;
    });

    try {
      final request = CreateBookingRequest(
        startDate: _startDate!,
        endDate: _endDate!,
        note: _noteController.text.trim(),
        roomId: _selectedRoomId!,
        userId: userId,
      );

      final booking = await _bookingService.createBooking(request);

      if (mounted) {
        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đặt phòng thành công!'),
            backgroundColor: Colors.green,
          ),
        );

        // Reset form
        setState(() {
          _startDate = null;
          _endDate = null;
          _selectedRoomId = null;
          _selectedRoom = null;
          _availableRooms = [];
          _noteController.clear();
          _isBooking = false;
        });

        // Hiển thị dialog với thông tin booking
        _showBookingSuccessDialog(booking);
      }
    } catch (e) {
      setState(() {
        _isBooking = false;
      });
      _showError('Đặt phòng thất bại: ${e.toString()}');
    }
  }

  void _showBookingSuccessDialog(Booking booking) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            const SizedBox(width: 12),
            const Text('Đặt phòng thành công'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Mã đặt phòng:', booking.id.substring(0, 8)),
            _buildInfoRow(
              'Ngày đến:',
              DateFormat('dd/MM/yyyy').format(booking.startDate),
            ),
            _buildInfoRow(
              'Ngày đi:',
              DateFormat('dd/MM/yyyy').format(booking.endDate),
            ),
            _buildInfoRow('Số đêm:', '${booking.numberOfNights} đêm'),
            _buildInfoRow(
              'Tổng tiền:',
              currencyFormat.format(booking.totalPrice),
            ),
            _buildInfoRow('Trạng thái:', booking.status),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt phòng'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pre-selected room info (hiển thị trước khi chọn ngày)
            if (widget.preSelectedRoomId != null && _selectedRoom != null)
              _buildPreSelectedRoomInfo(),

            // Date selection section
            _buildDateSelectionSection(),

            // Available rooms section (chỉ hiển thị nếu KHÔNG có pre-selected room)
            if (_availableRooms.isNotEmpty && widget.preSelectedRoomId == null)
              _buildAvailableRoomsSection(),

            // Loading indicator
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),

            // Note section (only show when room is selected)
            if (_selectedRoomId != null) _buildNoteSection(),

            // Selected room info
            if (_selectedRoom != null) _buildSelectedRoomInfo(),

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/rooms');
          }
        },
      ),
      floatingActionButton:
          _selectedRoomId != null && _startDate != null && _endDate != null
          ? FloatingActionButton.extended(
              onPressed: _isBooking ? null : _createBooking,
              backgroundColor: AppColors.primary,
              icon: _isBooking
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.check),
              label: Text(_isBooking ? 'Đang xử lý...' : 'Xác nhận đặt phòng'),
            )
          : null,
    );
  }

  Widget _buildDateSelectionSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chọn ngày',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDateButton(
                  label: 'Ngày đến',
                  date: _startDate,
                  onTap: _selectStartDate,
                  icon: Icons.calendar_today,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateButton(
                  label: 'Ngày đi',
                  date: _endDate,
                  onTap: _selectEndDate,
                  icon: Icons.event,
                ),
              ),
            ],
          ),
          if (_startDate != null && _endDate != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.night_shelter, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${_endDate!.difference(_startDate!).inDays} đêm',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateButton({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 16),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              date != null
                  ? DateFormat('dd/MM/yyyy').format(date)
                  : 'Chọn ngày',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: date != null ? Colors.black : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableRoomsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phòng trống (${_availableRooms.length})',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _availableRooms.length,
            itemBuilder: (context, index) {
              final room = _availableRooms[index];
              final isSelected = room.id == _selectedRoomId;
              return _buildRoomItem(room, isSelected);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRoomItem(Room room, bool isSelected) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final numberOfNights = _endDate != null && _startDate != null
        ? _endDate!.difference(_startDate!).inDays
        : 1;
    final totalPrice = room.finalPrice * numberOfNights;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRoomId = room.id;
          _selectedRoom = room;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Room image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                room.mainImage,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: const Icon(Icons.hotel),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            // Room info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.categoryName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Phòng #${room.id.substring(0, 8)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        currencyFormat.format(room.finalPrice),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: 14,
                        ),
                      ),
                      const Text(' / đêm', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  Text(
                    'Tổng: ${currencyFormat.format(totalPrice)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Selection indicator
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 20),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ghi chú',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Nhập ghi chú (tùy chọn)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedRoomInfo() {
    if (_selectedRoom == null || _startDate == null || _endDate == null) {
      return const SizedBox.shrink();
    }

    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final numberOfNights = _endDate!.difference(_startDate!).inDays;
    final totalPrice = _selectedRoom!.finalPrice * numberOfNights;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin đặt phòng',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          _buildInfoRow('Phòng:', _selectedRoom!.categoryName),
          _buildInfoRow(
            'Ngày đến:',
            DateFormat('dd/MM/yyyy').format(_startDate!),
          ),
          _buildInfoRow('Ngày đi:', DateFormat('dd/MM/yyyy').format(_endDate!)),
          _buildInfoRow('Số đêm:', '$numberOfNights đêm'),
          _buildInfoRow(
            'Giá mỗi đêm:',
            currencyFormat.format(_selectedRoom!.finalPrice),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng cộng:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                currencyFormat.format(totalPrice),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreSelectedRoomInfo() {
    final room = _selectedRoom!;
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Phòng đã chọn',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Room image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  room.mainImage,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.hotel, size: 40),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              // Room info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.categoryName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Phòng #${room.id.substring(0, 8)}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currencyFormat.format(room.finalPrice),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const Text(
                      'mỗi đêm',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Vui lòng chọn ngày đến và ngày đi để xác nhận đặt phòng',
                    style: TextStyle(fontSize: 13, color: Colors.blue[700]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
