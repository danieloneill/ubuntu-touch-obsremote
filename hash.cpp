#include "hash.h"

#include <QCryptographicHash>
#include <QMessageAuthenticationCode>
#include <QUuid>
#include <QVariant>

Hash::Hash(QQuickItem *parent):
    QQuickItem(parent)
{
    // By default, QQuickItem does not draw anything. If you subclass
    // QQuickItem to create a visual item, you will need to uncomment the
    // following line and re-implement updatePaintNode()

    // setFlag(ItemHasContents, true);
}

Hash::~Hash()
{
}

QByteArray Hash::hmac( const QByteArray &key, const QByteArray &message )
{
    QMessageAuthenticationCode code(QCryptographicHash::Sha1);
    code.setKey(key);
    code.addData(message);
    return code.result();
}

QString Hash::hmacHex( const QByteArray &key, const QByteArray &message )
{
    return QString( hmac( key, message ).toHex() );
}

QString Hash::hmacBase64( const QByteArray &key, const QByteArray &message )
{
    return QString( hmac( key, message ).toBase64() );
}

QByteArray Hash::sha256( const QVariant &data, bool asBinary )
{
    if( asBinary )
        return QCryptographicHash::hash( data.toByteArray(), QCryptographicHash::Sha256 );
    return QCryptographicHash::hash( data.toByteArray(), QCryptographicHash::Sha256 ).toHex();
}

QByteArray Hash::OBSAuth( const QByteArray &salt, const QByteArray &challenge, const QByteArray &password )
{
	QCryptographicHash shash( QCryptographicHash::Sha256 );
	shash.addData( password );
	shash.addData( salt );

	QByteArray arhash = shash.result().toBase64();

	QCryptographicHash achash( QCryptographicHash::Sha256 );
	achash.addData( arhash );
	achash.addData( challenge );

	QByteArray ar = achash.result().toBase64();

	return ar;
}

QString Hash::md5( const QVariant &data )
{
    return QString( QCryptographicHash::hash( data.toByteArray(), QCryptographicHash::Md5 ).toHex() );
}

QString Hash::toBase64(const QByteArray &data)
{
    return data.toBase64();
}

QByteArray Hash::fromBase64(const QByteArray &data)
{
    return QByteArray::fromBase64(data);
}

QString Hash::uuid()
{
    return QUuid::createUuid().toString();
}
