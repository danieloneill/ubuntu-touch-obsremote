#ifndef HASH_H
#define HASH_H

#include <QQuickItem>

class Hash : public QQuickItem
{
    Q_OBJECT
    Q_DISABLE_COPY(Hash)

public:
    Hash(QQuickItem *parent = 0);
    ~Hash();

    Q_INVOKABLE QByteArray hmac(const QByteArray &key, const QByteArray &message);
    Q_INVOKABLE QString hmacHex(const QByteArray &key, const QByteArray &message);
    Q_INVOKABLE QString hmacBase64(const QByteArray &key, const QByteArray &message);
    Q_INVOKABLE QString md5(const QVariant &data);
    Q_INVOKABLE QByteArray sha256(const QVariant &data, bool asBinary=false);
    Q_INVOKABLE QString toBase64(const QByteArray &data);
    Q_INVOKABLE QByteArray fromBase64(const QByteArray &data);
    Q_INVOKABLE QString uuid();

    Q_INVOKABLE QByteArray OBSAuth( const QByteArray &salt, const QByteArray &challenge, const QByteArray &password );
};

#endif // HASH_H

