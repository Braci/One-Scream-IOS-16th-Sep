/** 
   
   Copyright (c) 2015 One Scream Ltd.
   
   @file RWBuffer.h
   
   @date 2015-5-9
   
   @brief
   
    The class for buffering read and written data.
*/

#pragma once
#include "criticalsection.h"

class RWBuffer
{
public:
	RWBuffer(void)
	{
		m_pcBuffer = NULL;
		m_pfBuffer = NULL;

		m_nBufSize = 0;
		m_nWritePos = m_nReadPos = 0;
		m_pSync = &m_Sysn;
		m_externalMode = false;
	}

	~RWBuffer(void)
	{
		if(m_externalMode == false && m_pcBuffer)
		{
			delete m_pcBuffer;
		}
		m_pcBuffer = NULL;
		m_pfBuffer = NULL;
	}

	/**
	  @breif initialize the size of buffer
	*/
	bool Init( int p_nBufSize )
	{
		if(m_externalMode == true)
			return false;

		if(m_pSync) m_pSync->Enter();

		if (m_pcBuffer)
		{
			delete m_pcBuffer;
		}
		m_pcBuffer = new char[p_nBufSize];
		m_pfBuffer = (float*)m_pcBuffer;
		m_nBufSize = p_nBufSize;
		m_nReadPos = m_nWritePos = 0;

		if(m_pSync) m_pSync->Leave();

		return true;
	}

	/**
	  @breif initialize the buffer with specified parameters
	*/
	bool Init( char* p_buf, int p_bufSize, int p_readPos, int p_writePos )
	{
		m_pcBuffer = p_buf;
		m_pfBuffer = (float*)m_pcBuffer;
		m_nBufSize = p_bufSize;
		m_nReadPos = p_readPos;
		m_nWritePos = p_writePos;
		m_pSync = nullptr;

		m_externalMode = true;
		return false;
	}
	void GetCurPosition(int* p_readPos, int* p_writePos)
	{
		if(m_pSync) m_pSync->Enter();
		*p_readPos = m_nReadPos;
		*p_writePos = m_nWritePos;
		if(m_pSync) m_pSync->Leave();
	}

	/**
	  @breif Make the whole buffer writable
	*/
	void Reset()
	{
		if(m_pSync) m_pSync->Enter();

		m_nReadPos = m_nWritePos = 0;

		if(m_pSync) m_pSync->Leave();
	}

	/**
        Write Data to buffer
   
	   @param p_pData - the data to write
	   @param p_nBytes - the size to write
	   @return true/false
	   @warning 
	*/
	bool WriteData( void* p_pData, int p_nBytes )
	{
		if(GetWriteSpace() < p_nBytes)
		{
			return false;
		}

		if(m_pSync) m_pSync->Enter();

		if (true || m_nWritePos >= m_nReadPos)
		{
			int nRemain = m_nBufSize - m_nWritePos;
			if(nRemain >= p_nBytes)
			{
				if(p_pData)
					memcpy(m_pcBuffer + m_nWritePos, p_pData, p_nBytes);
				else
					memset(m_pcBuffer + m_nWritePos, 0, p_nBytes);
				m_nWritePos = (m_nWritePos + p_nBytes) % m_nBufSize;
			}
			else
			{
				if(p_pData)
					memcpy(m_pcBuffer + m_nWritePos, p_pData, nRemain);
				else
					memset(m_pcBuffer + m_nWritePos, 0, nRemain);

				p_nBytes -= nRemain;

				if(p_pData)
					memcpy(m_pcBuffer, (unsigned char*)p_pData+nRemain, p_nBytes);
				else
					memset(m_pcBuffer, 0, p_nBytes);

				m_nWritePos = p_nBytes;
			}
		}
		else
		{
			if(p_pData)
				memcpy(m_pcBuffer + m_nWritePos, p_pData, p_nBytes);
			else
				memset(m_pcBuffer + m_nWritePos, 0, p_nBytes);
			m_nWritePos += p_nBytes;
		}

		if(m_pSync) m_pSync->Leave();

		return true;
	}

	/**
        Read the data from buffer
   
	   @param p_pData - the data to read
	   @param p_nBytes - the size to read
	   @return true/false
	   @warning 
	*/
	bool ReadData( void* p_pData, int p_nBytes )
	{
		if(GetReadSpace() < p_nBytes)
		{
			return false;
		}

		if(m_pSync) m_pSync->Enter();

		if (false && m_nWritePos >= m_nReadPos)
		{
			if(p_pData)
			{
				memcpy(p_pData, m_pcBuffer + m_nReadPos, p_nBytes);
			}
			m_nReadPos += p_nBytes;
		}
		else
		{
			int nRemain = m_nBufSize - m_nReadPos;
			if(nRemain >= p_nBytes)
			{
				if(p_pData)
				{
					memcpy(p_pData, m_pcBuffer + m_nReadPos, p_nBytes);
				}
				m_nReadPos = (m_nReadPos + p_nBytes) % m_nBufSize;
			}
			else
			{
				if(p_pData)
				{
					memcpy(p_pData, m_pcBuffer + m_nReadPos, nRemain);
				}
				p_nBytes -= nRemain;

				if(p_pData)
				{
					memcpy((unsigned char*)p_pData + nRemain, m_pcBuffer, p_nBytes);
				}
				m_nReadPos = p_nBytes;
			}
		}

		if(m_pSync) m_pSync->Leave();

		return true;
	}

	/**
	   Get Writable size
     
	   @return The writable size
	   @warning 
	*/
	int GetWriteSpace()
	{
		int nSize;
		if(m_pSync) m_pSync->Enter();

		if (m_nWritePos >= m_nReadPos)
		{
			nSize = m_nBufSize - m_nWritePos + m_nReadPos;
		}
		else
		{
			nSize = m_nReadPos - m_nWritePos;
		}

		if(m_pSync) m_pSync->Leave();

		return nSize;
	}

	/**
        Get Readable size
	   @return The readable size
	   @warning 
	*/
	int GetReadSpace()
	{
		return m_nBufSize - GetWriteSpace();
	}
	int getNumSamples()
	{
		return GetBufSize()/sizeof(float);
	}
	float* getSampleData(int, int)
	{
		return m_pfBuffer;
	}

	int GetBufSize(){ return m_nBufSize; }

	void EmptyBack(int p_nBytes)
	{
		if(GetReadSpace() > p_nBytes)
		{
			if(m_pSync) m_pSync->Enter();

			m_nWritePos -= p_nBytes;
			if (m_nWritePos < 0)
			{
				m_nWritePos += m_nBufSize;
			}

			if(m_pSync) m_pSync->Leave();
		}
		else
		{
			Reset();
		}
	}

private:

	int		m_nReadPos;
	int		m_nWritePos;

	char*	m_pcBuffer;
	float*	m_pfBuffer;
	int		m_nBufSize;

	bool	m_externalMode;

	Sync::CriticalSection	m_Sysn;
	Sync::CriticalSection*	m_pSync;
};
