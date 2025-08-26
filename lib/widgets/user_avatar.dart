import '../exports/package_exports.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    this.imageUrl,
    this.radius = 30,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ImageProvider<Object> placeholder = const AssetImage('assets/images/default_avatar.png');

    final validImage = imageUrl != null && imageUrl!.trim().isNotEmpty;
    
    final ImageProvider<Object> imageProvider = validImage
        ? CachedNetworkImageProvider(imageUrl!) 
        : placeholder;

    Widget avatar = CircleAvatar(
      radius: radius,
      backgroundImage: imageProvider,
      backgroundColor: Theme.of(context).colorScheme.primary,
    );

    return onTap != null
      ? GestureDetector(onTap: onTap, child: avatar)
      : avatar;
  }
}